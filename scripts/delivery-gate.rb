#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "optparse"
require "pathname"
require "yaml"
require_relative "../lib/verdify"

ROOT = Pathname.new(File.expand_path("..", __dir__))
options = {
  event: nil,
  repo: nil,
  reviews: nil,
  config: ROOT.join("config/github-primitives.yaml").to_s,
  prepare_release_event: nil,
  expected_head: nil
}

OptionParser.new do |parser|
  parser.banner = "Usage: ruby scripts/delivery-gate.rb --event EVENT.json --repo CANDIDATE [--reviews REVIEWS.json]"
  parser.on("--event PATH") { |value| options[:event] = value }
  parser.on("--repo PATH") { |value| options[:repo] = value }
  parser.on("--reviews PATH") { |value| options[:reviews] = value }
  parser.on("--config PATH") { |value| options[:config] = value }
  parser.on("--prepare-release-event PULLS.json") { |value| options[:prepare_release_event] = value }
  parser.on("--expected-head SHA") { |value| options[:expected_head] = value }
  parser.on("-h", "--help") { puts parser; exit 0 }
end.parse!

def full_sha?(value)
  value.to_s.match?(/\A[0-9a-f]{40}\z/i)
end

def load_json(path, label)
  JSON.parse(File.read(path))
rescue Errno::ENOENT, JSON::ParserError => e
  warn "#{label} could not be loaded: #{e.message}"
  exit 2
end

def latest_effective_reviews(reviews)
  effective = Array(reviews).select do |review|
    %w[APPROVED CHANGES_REQUESTED DISMISSED].include?(review["state"].to_s.upcase)
  end
  effective.group_by { |review| review.dig("user", "login").to_s.downcase }.transform_values do |history|
    history.max_by { |review| [review["submitted_at"].to_s, review["id"].to_i] }
  end
end

# Shared by the dev -> main release route and the dev fleet-contract-sync
# route: both need a real, current-head, non-author GitHub review from an
# allowed owner -- not merely a CODEOWNERS auto-request. (Confirmed against
# this repo's own history: with required_approving_review_count: 0,
# require_code_owner_reviews only auto-requests an owner as a reviewer; it
# does not block a merge without their approval. PRs #213/#230/#222 merged
# into dev touching CODEOWNERS-protected paths with zero reviews.) This is
# the one place that requirement is mechanically enforced for either route.
def owner_approval_errors(reviews, head_sha:, author:, allowed_approvers:, requirement:)
  errors = []
  latest = latest_effective_reviews(reviews)
  unresolved = latest.values.select { |review| review["state"].to_s.upcase == "CHANGES_REQUESTED" }
  unless unresolved.empty?
    errors << "an effective change-request review remains unresolved: #{unresolved.filter_map { |review| review.dig('user', 'login') }.sort.join(', ')}"
  end
  approval = latest.values.find do |review|
    login = review.dig("user", "login").to_s.downcase
    type = review.dig("user", "type").to_s
    allowed_approvers.include?(login) &&
      login != author &&
      type == "User" &&
      !login.end_with?("[bot]") &&
      review["state"].to_s.upcase == "APPROVED" &&
      review["commit_id"] == head_sha
  end
  errors << "#{requirement} requires a current-head APPROVED review by #{allowed_approvers.join(' or ')} other than the author" unless approval
  errors
end

config = YAML.safe_load(File.read(options[:config]), permitted_classes: [], aliases: false)
flow = config.fetch("release_branch_flow")
development_branch = flow.fetch("development_branch")
release_branch = flow.fetch("release_branch")
expected_repository = flow.fetch("repository")
allowed_release_approvers = Array(flow.fetch("allowed_release_approvers")).map(&:downcase)
errors = []

errors << "delivery configuration must name dev and main" unless development_branch == "dev" && release_branch == "main"
errors << "delivery configuration must name both release owners" unless allowed_release_approvers.sort == %w[jrvallery jvallery]

if options[:prepare_release_event]
  expected_head = options[:expected_head].to_s
  errors << "--expected-head must be a full 40-character commit SHA" unless full_sha?(expected_head)
  pulls = load_json(options[:prepare_release_event], "open pull requests")
  matches = Array(pulls).select do |pull_request|
    pull_request["state"].to_s.downcase == "open" &&
      pull_request.dig("base", "ref") == release_branch &&
      pull_request.dig("head", "ref") == development_branch &&
      pull_request.dig("base", "repo", "full_name") == expected_repository &&
      pull_request.dig("head", "repo", "full_name") == expected_repository &&
      pull_request.dig("head", "sha") == expected_head
  end
  errors << "expected exactly one open same-repository dev-to-main release PR at #{expected_head}, found #{matches.length}" unless matches.length == 1
  if errors.empty?
    pull_request = matches.first
    puts JSON.generate(
      "number" => pull_request["number"],
      "repository" => pull_request.fetch("base").fetch("repo"),
      "pull_request" => pull_request
    )
    exit 0
  end
elsif options[:event].to_s.empty? || options[:repo].to_s.empty?
  warn "--event and --repo are required unless --prepare-release-event is used"
  exit 2
else
  event = load_json(options[:event], "event")
  pull_request = event["pull_request"]
  if !pull_request.is_a?(Hash)
    errors << "delivery gate requires a pull request event"
  else
    base_ref = pull_request.dig("base", "ref").to_s
    head_ref = pull_request.dig("head", "ref").to_s
    base_sha = pull_request.dig("base", "sha").to_s
    head_sha = pull_request.dig("head", "sha").to_s
    event_repository = event.dig("repository", "full_name").to_s
    base_repository = pull_request.dig("base", "repo", "full_name").to_s
    head_repository = pull_request.dig("head", "repo", "full_name").to_s
    author = pull_request.dig("user", "login").to_s.downcase
    candidate = Verdify::GitRepository.new(options[:repo])

    errors << "event repository must be #{expected_repository}" unless event_repository == expected_repository
    errors << "candidate checkout head does not match the pull request head" unless full_sha?(head_sha) && candidate.head_sha == head_sha

    if base_ref == development_branch
      body = pull_request["body"].to_s
      changed_paths = if full_sha?(base_sha) && candidate.commit_exists?(base_sha)
                        candidate.git("diff", "--name-only", "#{base_sha}...#{head_sha}").first.lines.map(&:strip).reject(&:empty?).uniq.sort
                      else
                        []
                      end
      marker_pattern = /<!--[ \t]*verdify-terminal-receipt:([a-z0-9][a-z0-9-]*):([0-9a-f]{40})[ \t]*-->/
      markers = body.scan(marker_pattern)
      marker_comments = body.scan(/<!--[ \t]*verdify-terminal-receipt:[^\n]*?-->/)
      receipt_paths = changed_paths.grep(%r{\A\.agent-workflow/sprints/[^/]+/terminal/terminal-receipt\.yaml\z})
      receipt_pr = !markers.empty? || !marker_comments.empty? || !receipt_paths.empty?
      cutover_active = full_sha?(base_sha) && candidate.git(
        "cat-file", "-e", "#{base_sha}:schemas/sprint-terminal-receipt.schema.yaml", allow_failure: true
      ).last.success?
      unterminated = if cutover_active
                       Verdify::SprintTerminalReceipt.new(repo: candidate).integrated_unterminated_sprints(ref: base_sha)
                     else
                       []
                     end

      if receipt_pr
        errors << "terminal receipt gate requires exactly one valid marker" unless markers.length == 1 && marker_comments.length == 1
        marker_id, marker_base = markers.first || []
        errors << "terminal receipt marker base must match the pull request base" unless marker_base == base_sha
        receipt_mode = marker_id == Verdify::SprintTerminalReceipt::RECOVERY_BUNDLE ? "recovery" : "normal"
        sprint_ids = receipt_paths.filter_map { |path| Verdify::SprintTerminalReceipt.sprint_id_from_receipt_path(path) }.uniq.sort
        expected_sprints = if receipt_mode == "recovery"
                             Verdify::SprintTerminalReceipt::RECOVERY_SPRINT_IDS
                           elsif marker_id
                             [marker_id]
                           else
                             []
                           end
        errors << "terminal receipt marker and sprint set do not match" unless sprint_ids == expected_sprints.sort
        errors << "terminal receipt must resolve exactly the integrated unterminated sprint set" unless sprint_ids == unterminated
        errors << "terminal receipt gate rejects mixed or incomplete paths" unless changed_paths == Verdify::SprintTerminalReceipt.allowed_receipt_paths(expected_sprints)
        expected_branch = marker_base && "receipt/#{receipt_mode == 'recovery' ? Verdify::SprintTerminalReceipt::RECOVERY_BUNDLE : marker_id}/#{marker_base[0, 12]}"
        errors << "terminal receipt branch must be #{expected_branch}" unless expected_branch && head_ref == expected_branch
        validator = Verdify::SprintTerminalReceipt.new(repo: candidate)
        sprint_ids.each do |sprint_id|
          result = validator.validate_full(
            receipt_path: candidate.root.join(Verdify::SprintTerminalReceipt.paths(sprint_id).fetch(:receipt)),
            expected_base_sha: base_sha,
            expected_mode: receipt_mode
          )
          errors.concat(result.errors.map { |error| "#{sprint_id}: #{error}" })
        end
      else
        unless unterminated.empty?
          errors << "integrated sprint(s) require terminal receipts before another implementation can merge: #{unterminated.join(', ')}"
        end

        pr_labels = Array(pull_request["labels"]).map { |label| label.is_a?(Hash) ? label["name"].to_s : label.to_s }
        fleet_contract_sync_label = config.dig("managed_fleet_contract", "label").to_s
        fleet_contract_sync_label = "verdify:fleet-contract-sync" if fleet_contract_sync_label.empty?
        fleet_contract_sync = pr_labels.include?(fleet_contract_sync_label)

        if fleet_contract_sync
          # The only pull-request class exempt from the lane/contract/critic
          # chain below, and only once BOTH conditions hold: (a)
          # Verdify::ManagedContractDiff mechanically proves the diff touches
          # nothing but the managed contract surface (jvallery/agents#3577,
          # #3044), and (b) a current-head APPROVED review from a non-author
          # allowed owner is present (see owner_approval_errors above --
          # CODEOWNERS alone does not enforce this on a zero-review-count
          # branch). A pull request that carries the label but fails either
          # check is rejected here, never silently re-routed into the lane
          # path below.
          if !(full_sha?(base_sha) && candidate.commit_exists?(base_sha))
            errors << "fleet contract sync requires an existing base commit to verify diff confinement"
          else
            confinement = Verdify::ManagedContractDiff.evaluate(repo: candidate, base_sha: base_sha, head_sha: head_sha)
            errors.concat(confinement.errors)
          end
          reviews = options[:reviews] ? load_json(options[:reviews], "reviews") : []
          errors.concat(owner_approval_errors(reviews, head_sha: head_sha, author: author, allowed_approvers: allowed_release_approvers, requirement: "fleet contract sync"))
        else
          lane_id = body[/^- Lane:\s*`?([^`\n]+)`?\s*$/i, 1]&.strip
          contract_relative = body[/^- Contract:\s*`?([^`\n]+)`?\s*$/i, 1]&.strip
          unless lane_id.to_s.match?(/\A[a-z0-9][a-z0-9-]*\z/) && contract_relative.to_s.match?(%r{\A\.agent-workflow/sprints/[^/]+/lanes/contracts/[^/]+\.contract\.ya?ml\z})
            errors << "dev critic gate requires exact lane and contract metadata"
          else
            contract_path = candidate.root.join(contract_relative)
            sprint_root = contract_path.dirname.parent.parent
            closeout_path = sprint_root.join("lanes/closeout/#{lane_id}.closeout.yaml")
            critic_path = sprint_root.join("critic/#{lane_id}.critic.yaml")
            if !critic_path.file?
              errors << "current head does not contain the canonical critic report"
            else
              validator = Verdify::LaneReviewValidator.new(
                repo: candidate,
                contract_path: contract_path,
                closeout_path: closeout_path,
                critic_path: critic_path
              )
              result = validator.validate_critic(tip_sha: head_sha)
              status = validator.validate_critic_status(result: result, pull_request_head_sha: head_sha)
              errors.concat(status.errors)
              expected_pull_request = pull_request["number"] || event["number"]
              if status.critic && status.critic["pull_request"] != expected_pull_request
                errors << "critic report pull request does not match the event"
              end
            end
          end
        end
      end
    elsif base_ref == release_branch
      unless head_ref == development_branch &&
             base_repository == expected_repository &&
             head_repository == expected_repository &&
             event_repository == expected_repository
        errors << "main critic gate accepts only the same-repository dev-to-main release route"
      end
      reviews = options[:reviews] ? load_json(options[:reviews], "reviews") : []
      errors.concat(owner_approval_errors(reviews, head_sha: head_sha, author: author, allowed_approvers: allowed_release_approvers, requirement: "main"))
    else
      errors << "delivery gate accepts only dev integration or main release pull requests"
    end
  end
end

if errors.empty?
  puts "Verdify critic gate passed."
  exit 0
end

warn "Verdify critic gate failed:"
errors.uniq.each { |error| warn "  - #{error}" }
exit 1
