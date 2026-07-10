#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "optparse"
require "pathname"
require "yaml"
require_relative "../lib/verdify"

ROOT = Pathname.new(File.expand_path("..", __dir__))
options = { event: nil, body: nil, base: nil, head: nil, base_ref: nil, head_ref: nil, labels: [], repo: nil }
OptionParser.new do |o|
  o.banner = "Usage: ruby scripts/pr-policy.rb --event EVENT.json | --body FILE " \
             "[--base SHA --head SHA --base-ref REF --head-ref REF] [--label NAME]"
  o.on("--event PATH") { |v| options[:event] = v }
  o.on("--body PATH") { |v| options[:body] = v }
  o.on("--base SHA") { |v| options[:base] = v }
  o.on("--head SHA") { |v| options[:head] = v }
  o.on("--base-ref REF") { |v| options[:base_ref] = v }
  o.on("--head-ref REF") { |v| options[:head_ref] = v }
  o.on("--label NAME") { |v| options[:labels] << v }
  o.on("--repo PATH", "Validate candidate metadata and release files against this full Git checkout") { |v| options[:repo] = v }
  o.on("-h", "--help") { puts o; exit 0 }
end.parse!
options[:event] ||= ENV["GITHUB_EVENT_PATH"] if options[:body].nil?

errors = []
body = ""
base_sha = options[:base]
head_sha = options[:head]
base_ref = options[:base_ref]
head_ref = options[:head_ref]
labels = options[:labels].dup
event_payload = nil
base_repository = nil
head_repository = nil
event_repository = nil

if options[:body]
  body = File.read(options[:body])
elsif options[:event]
  event_payload = JSON.parse(File.read(options[:event]))
  pr = event_payload.fetch("pull_request")
  body = pr["body"].to_s
  base_sha ||= pr.dig("base", "sha")
  head_sha ||= pr.dig("head", "sha")
  base_ref ||= pr.dig("base", "ref")
  head_ref ||= pr.dig("head", "ref")
  base_repository = pr.dig("base", "repo", "full_name") || event_payload.dig("repository", "full_name")
  head_repository = pr.dig("head", "repo", "full_name")
  event_repository = event_payload.dig("repository", "full_name")
  labels.concat(Array(pr["labels"]).map { |l| l.is_a?(Hash) ? l["name"].to_s : l.to_s })
else
  warn "--event or --body is required"
  exit 2
end

config = YAML.safe_load(ROOT.join("config/github-primitives.yaml").read, permitted_classes: [], aliases: false)

# Mode selection, in precedence order:
# 1. release: the generated dev -> main release PR (decided by refs; labels cannot demote it);
# 2. lightweight: an exempt-labelled PR using the reduced contract;
# 3. standard: the full implementation-lane contract.
development_branch = config.dig("release_branch_flow", "development_branch") || "dev"
release_branch = config.dig("release_branch_flow", "release_branch") || "main"
configured_repository = config.dig("release_branch_flow", "repository").to_s
release_refs = base_ref == release_branch && head_ref == development_branch
same_repository = event_payload.nil? || (
  !event_repository.to_s.empty? &&
  base_repository == event_repository &&
  head_repository == event_repository
)
release_pr = release_refs && same_repository
errors << "cross-repository pull requests cannot use the privileged release path" if release_refs && !same_repository
if release_refs && event_payload && !configured_repository.empty? && event_repository != configured_repository
  errors << "release route repository must be #{configured_repository}"
end
if base_ref == release_branch && head_ref != development_branch
  errors << "main accepts only the exact dev-to-main release route"
elsif !base_ref.to_s.empty? && base_ref != development_branch && !release_refs
  errors << "ordinary pull requests must target dev"
end
exempt_labels = Array(config["lightweight_pull_request_labels"])
exempt_labels = %w[verdify:policy-exempt type:docs type:chore] if exempt_labels.empty?
lightweight = !release_pr && labels.any? { |label| exempt_labels.include?(label) }
lane = nil
contract = nil

if lightweight && options[:repo]
  begin
    candidate_repo = Verdify::GitRepository.new(options[:repo])
    errors << "checked-out repository head does not match pull request head" unless !head_sha || candidate_repo.head_sha == head_sha
    unless base_sha && head_sha && candidate_repo.commit_exists?(base_sha) && candidate_repo.commit_exists?(head_sha)
      errors << "lightweight policy requires existing base and head commits"
    else
      changed_paths = candidate_repo.git("diff", "--name-only", "#{base_sha}...#{head_sha}").first.lines.map(&:strip).reject(&:empty?)
      explicit_policy_exception = labels.include?("verdify:policy-exempt")
      docs_only = !changed_paths.empty? && changed_paths.all? do |path|
        path.start_with?("docs/", ".github/ISSUE_TEMPLATE/")
      end
      unless explicit_policy_exception || docs_only
        errors << "lightweight labels require a docs-only diff or the explicit verdify:policy-exempt label"
      end
    end
  rescue Verdify::Error => e
    errors << "could not validate lightweight candidate paths: #{e.message}"
  end
end

# Every PR, in every mode, must link the issue it closes.
closing = body.scan(/\b(?:close[sd]?|fix(?:e[sd])?|resolve[sd]?)\s*:?[ \t]+#(\d+)\b/i).flatten.map(&:to_i).uniq
errors << "PR body must link at least one issue with a closing keyword" if closing.empty?

if release_pr
  Array(config["required_release_pull_request_sections"]).each do |section|
    errors << "missing required section: ## #{section}" unless body.match?(/^##\s+#{Regexp.escape(section)}\s*$/i)
  end

  candidate_root = options[:repo] ? Verdify::GitRepository.new(options[:repo]).root : ROOT
  if options[:repo] && head_sha
    errors << "checked-out repository head does not match pull request head" unless Verdify::GitRepository.new(candidate_root).head_sha == head_sha
  end
  package_path = candidate_root.join("package.json")
  version_path = candidate_root.join("VERSION")
  [package_path, version_path].each do |path|
    unless path.file? && !path.symlink? && path.realpath.dirname == candidate_root
      errors << "release identity file must be a regular top-level candidate file: #{path.basename}"
    end
  end
  package = package_path.file? && !package_path.symlink? ? JSON.parse(package_path.read) : {}
  version = version_path.file? && !version_path.symlink? ? version_path.read.strip : ""
  package_version = package["version"].to_s
  body_version = body[/^- VERSION:\s*`?([^`\n]+)`?\s*$/i, 1]&.strip
  package_line = body[/^- Package:\s*`?([^`\n]+)`?\s*$/i, 1]&.strip

  errors << "package.json version does not match VERSION" unless package_version == version
  errors << "release PR VERSION must be #{version}" unless body_version == version
  package_name = package["name"].to_s
  errors << "release package.json must define name and version" if package_name.empty? || package_version.empty?
  errors << "release PR package line must be #{package_name}@#{version}" unless package_line == "#{package_name}@#{version}"
  expected_marker = "<!-- verdify-release-candidate:#{package_name}@#{version} -->"
  release_markers = body.scan(/<!--[ \t]*verdify-release-candidate:[^\n]*?-->/)
  errors << "release PR must contain exactly the durable marker #{expected_marker}" unless release_markers == [expected_marker]
  errors << "release marker must be the first non-whitespace content" unless body.lstrip.start_with?(expected_marker)
elsif lightweight
  # Reduced contract for docs/chore/exempt PRs: outcome + evidence only.
  %w[Outcome Evidence].each do |section|
    errors << "missing required section: ## #{section}" unless body.match?(/^##\s+#{Regexp.escape(section)}\s*$/i)
  end
else
  Array(config["required_pull_request_sections"]).each do |section|
    errors << "missing required section: ## #{section}" unless body.match?(/^##\s+#{Regexp.escape(section)}\s*$/i)
  end

  lane = body[/^- Lane:\s*`?([^`\n]+)`?\s*$/i, 1]&.strip
  contract = body[/^- Contract:\s*`?([^`\n]+)`?\s*$/i, 1]&.strip
  errors << "lane ID is missing or still a placeholder" if lane.to_s.empty? || lane.include?("<!--")
  errors << "lane contract path is missing or still a placeholder" if contract.to_s.empty? || contract.include?("<!--")
  errors << "lane contract must be under .agent-workflow/sprints/.../lanes/contracts" unless contract.to_s.match?(%r{\A\.agent-workflow/sprints/[^/]+/lanes/contracts/[^/]+\.contract\.ya?ml\z})
end

implementation_head = body[/^Implementation head SHA:\s*`?([0-9a-f]{40})`?\s*$/i, 1]
evidence_head = body[/^Evidence head SHA:\s*`?([0-9a-f]{40}|pending)`?\s*$/i, 1]&.downcase
reported_head = body[/^Current head SHA:\s*`?([0-9a-f]{40})`?\s*$/i, 1]
reported_baseline = body[/^- Baseline SHA:\s*`?([0-9a-f]{40})`?\s*$/i, 1]
if release_pr
  # Release PR bodies are generated with the head SHA, so presence stays
  # mandatory; the value is not compared because dev may legitimately advance
  # after the body is generated (release SHA race).
  errors << "Current head SHA must be a 40-character commit SHA" unless reported_head
elsif lightweight
  errors << "reported head SHA does not match the pull request head" if reported_head && head_sha && reported_head != head_sha
else
  errors << "Baseline SHA must be a 40-character commit SHA" unless reported_baseline
  errors << "Implementation head SHA must be a 40-character commit SHA" unless implementation_head
  errors << "Evidence head SHA must be a 40-character commit SHA or pending" unless evidence_head
  errors << "Current head SHA must be a 40-character commit SHA" unless reported_head
  errors << "reported head SHA does not match the pull request head" if reported_head && head_sha && reported_head != head_sha
  if evidence_head == "pending" && implementation_head && reported_head && implementation_head != reported_head
    errors << "Evidence head SHA may be pending only while Current head SHA equals Implementation head SHA"
  end
end
errors << "base and head SHA are identical" if base_sha && head_sha && base_sha == head_sha

if !release_pr && !lightweight && options[:repo] && implementation_head && evidence_head && reported_head && reported_baseline && lane && contract
  begin
    repo = Verdify::GitRepository.new(options[:repo])
    errors << "checked-out repository head does not match pull request head" unless repo.head_sha == head_sha
    metadata_shas = [reported_baseline, implementation_head, reported_head]
    metadata_shas << evidence_head unless evidence_head == "pending"
    metadata_shas.each do |sha|
      errors << "pull request metadata references missing commit #{sha}" unless repo.commit_exists?(sha)
    end
    if repo.commit_exists?(reported_baseline) && repo.commit_exists?(implementation_head) && !repo.ancestor?(reported_baseline, implementation_head)
      errors << "Baseline SHA must be an ancestor of Implementation head SHA"
    end
    contract_path = repo.root.join(contract)
    errors << "lane contract is not present in the checked-out head" unless contract_path.file?
    if contract_path.file?
      contract_document = Verdify.safe_load_yaml(contract_path)
      contract_schema = Verdify::SchemaValidator.load_document(Verdify::ROOT.join("schemas/lane-contract.schema.yaml"))
      contract_errors = Verdify::SchemaValidator.new.validate(contract_document, contract_schema) + Verdify::SemanticValidator.validate(contract_document)
      errors.concat(contract_errors.map { |error| "lane contract: #{error}" })
      errors << "PR lane ID does not match lane contract" unless contract_document["lane_id"] == lane
      errors << "PR Baseline SHA does not match lane contract" unless contract_document["baseline_sha"] == reported_baseline
      unless %w[approved dispatched changes_requested].include?(contract_document["status"]) && contract_document.dig("approval", "status") == "approved"
        errors << "lane contract is not approved for execution"
      end
    end
    if evidence_head == "pending"
      errors << "pending evidence requires the checked-out head to equal Implementation head SHA" unless repo.head_sha == implementation_head
      if contract_path.file? && repo.commit_exists?(implementation_head)
        errors << "working lane contract does not match Implementation head SHA" unless contract_path.binread == repo.file_at(implementation_head, contract)
      end
    elsif repo.commit_exists?(evidence_head)
      sprint_root = Pathname.new(contract).dirname.parent.parent
      closeout_path = repo.root.join(sprint_root, "lanes/closeout/#{lane}.closeout.yaml")
      critic_path = repo.root.join(sprint_root, "critic/#{lane}.critic.yaml")
      review_validator = Verdify::LaneReviewValidator.new(
        repo: repo,
        contract_path: contract_path,
        closeout_path: closeout_path,
        critic_path: critic_path.file? ? critic_path : nil
      )
      validation = if critic_path.file?
                     review_validator.validate_critic(tip_sha: reported_head)
                   else
                     review_validator.validate_closeout(evidence_head_sha: evidence_head)
                   end
      errors.concat(validation.errors.map { |error| "lane evidence: #{error}" })
      errors << "Implementation head SHA does not match lane evidence" unless validation.implementation_head_sha == implementation_head
      errors << "Evidence head SHA does not match lane evidence" unless validation.evidence_head_sha == evidence_head
      if critic_path.file? && validation.critic_report_head_sha != reported_head
        errors << "Current head SHA must be the critic-report commit"
      elsif !critic_path.file? && evidence_head != reported_head
        errors << "Current head SHA must equal Evidence head SHA until the critic report is committed"
      end
    else
      errors << "Evidence head SHA does not exist in the checked-out repository"
    end
  rescue Verdify::Error => e
    errors << "could not validate lane evidence Git history: #{e.message}"
  end
end

allowed_html_comments = release_pr && defined?(expected_marker) ? [expected_marker] : []
unresolved_html_comments = body.scan(/<!--.*?-->/m) - allowed_html_comments
if unresolved_html_comments.any?
  errors << "pull request template still contains unresolved HTML placeholders"
end

if errors.empty?
  kind = release_pr ? "release" : "implementation"
  mode = lightweight ? " (lightweight)" : ""
  puts "Verdify #{kind} pull request policy passed#{mode} for issue(s): #{closing.map { |n| "##{n}" }.join(', ')}"
  exit 0
end
warn "Verdify pull request policy failed:"
errors.each { |error| warn "  - #{error}" }
exit 1
