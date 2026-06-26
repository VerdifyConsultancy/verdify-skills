#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "optparse"
require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("..", __dir__))
options = { event: nil, body: nil, base: nil, head: nil, base_ref: nil, head_ref: nil }
OptionParser.new do |o|
  o.banner = "Usage: ruby scripts/pr-policy.rb --event EVENT.json | --body FILE [--base SHA --head SHA --base-ref REF --head-ref REF]"
  o.on("--event PATH") { |v| options[:event] = v }
  o.on("--body PATH") { |v| options[:body] = v }
  o.on("--base SHA") { |v| options[:base] = v }
  o.on("--head SHA") { |v| options[:head] = v }
  o.on("--base-ref REF") { |v| options[:base_ref] = v }
  o.on("--head-ref REF") { |v| options[:head_ref] = v }
  o.on("-h", "--help") { puts o; exit 0 }
end.parse!
options[:event] ||= ENV["GITHUB_EVENT_PATH"] if options[:body].nil?

errors = []
body = ""
base_sha = options[:base]
head_sha = options[:head]
base_ref = options[:base_ref]
head_ref = options[:head_ref]

if options[:body]
  body = File.read(options[:body])
elsif options[:event]
  payload = JSON.parse(File.read(options[:event]))
  pr = payload.fetch("pull_request")
  body = pr["body"].to_s
  base_sha ||= pr.dig("base", "sha")
  head_sha ||= pr.dig("head", "sha")
  base_ref ||= pr.dig("base", "ref")
  head_ref ||= pr.dig("head", "ref")
else
  warn "--event or --body is required"
  exit 2
end

config = YAML.safe_load(ROOT.join("config/github-primitives.yaml").read, permitted_classes: [], aliases: false)
release_pr = base_ref == "main" && head_ref == "dev"
sections = Array(config[release_pr ? "required_release_pull_request_sections" : "required_pull_request_sections"])
sections.each do |section|
  errors << "missing required section: ## #{section}" unless body.match?(/^##\s+#{Regexp.escape(section)}\s*$/i)
end

closing = body.scan(/\b(?:close[sd]?|fix(?:e[sd])?|resolve[sd]?)\s*:?[ \t]+#(\d+)\b/i).flatten.map(&:to_i).uniq
errors << "PR body must link at least one issue with a closing keyword" if closing.empty?

if release_pr
  package = JSON.parse(ROOT.join("package.json").read)
  version = ROOT.join("VERSION").read.strip
  package_version = package.fetch("version").to_s
  body_version = body[/^- VERSION:\s*`?([^`\n]+)`?\s*$/i, 1]&.strip
  package_line = body[/^- Package:\s*`?([^`\n]+)`?\s*$/i, 1]&.strip

  errors << "package.json version does not match VERSION" unless package_version == version
  errors << "release PR VERSION must be #{version}" unless body_version == version
  errors << "release PR package line must be #{package.fetch('name')}@#{version}" unless package_line == "#{package.fetch('name')}@#{version}"
else
  lane = body[/^- Lane:\s*`?([^`\n]+)`?\s*$/i, 1]&.strip
  contract = body[/^- Contract:\s*`?([^`\n]+)`?\s*$/i, 1]&.strip
  errors << "lane ID is missing or still a placeholder" if lane.to_s.empty? || lane.include?("<!--")
  errors << "lane contract path is missing or still a placeholder" if contract.to_s.empty? || contract.include?("<!--")
  errors << "lane contract must be under .agent-workflow/sprints/.../lanes/contracts" unless contract.to_s.match?(%r{\A\.agent-workflow/sprints/[^/]+/lanes/contracts/[^/]+\.contract\.ya?ml\z})
end

reported_head = body[/^Current head SHA:\s*`?([0-9a-f]{40})`?\s*$/i, 1]
errors << "Current head SHA must be a 40-character commit SHA" unless reported_head
errors << "reported head SHA does not match the pull request head" if !release_pr && reported_head && head_sha && reported_head != head_sha
errors << "base and head SHA are identical" if base_sha && head_sha && base_sha == head_sha

if body.include?("<!--")
  errors << "pull request template still contains unresolved HTML placeholders"
end

if errors.empty?
  kind = release_pr ? "release" : "implementation"
  puts "Verdify #{kind} pull request policy passed for issue(s): #{closing.map { |n| "##{n}" }.join(', ')}"
  exit 0
end
warn "Verdify pull request policy failed:"
errors.each { |e| warn "  - #{e}" }
exit 1
