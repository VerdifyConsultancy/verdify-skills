#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "optparse"
require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("..", __dir__))
options = { event: nil, body: nil, base: nil, head: nil, labels: [] }
OptionParser.new do |o|
  o.banner = "Usage: ruby scripts/pr-policy.rb --event EVENT.json | --body FILE [--base SHA --head SHA] [--label NAME]"
  o.on("--event PATH") { |v| options[:event] = v }
  o.on("--body PATH") { |v| options[:body] = v }
  o.on("--base SHA") { |v| options[:base] = v }
  o.on("--head SHA") { |v| options[:head] = v }
  o.on("--label NAME") { |v| options[:labels] << v }
  o.on("-h", "--help") { puts o; exit 0 }
end.parse!
options[:event] ||= ENV["GITHUB_EVENT_PATH"] if options[:body].nil?

errors = []
body = ""
base_sha = options[:base]
head_sha = options[:head]
labels = options[:labels].dup

if options[:body]
  body = File.read(options[:body])
elsif options[:event]
  payload = JSON.parse(File.read(options[:event]))
  pr = payload.fetch("pull_request")
  body = pr["body"].to_s
  base_sha ||= pr.dig("base", "sha")
  head_sha ||= pr.dig("head", "sha")
  labels.concat(Array(pr["labels"]).map { |l| l.is_a?(Hash) ? l["name"].to_s : l.to_s })
else
  warn "--event or --body is required"
  exit 2
end

config = YAML.safe_load(ROOT.join("config/github-primitives.yaml").read, permitted_classes: [], aliases: false)
exempt_labels = Array(config["lightweight_pull_request_labels"])
exempt_labels = %w[verdify:policy-exempt type:docs type:chore] if exempt_labels.empty?
lightweight = labels.any? { |label| exempt_labels.include?(label) }

# Every PR, lane or not, must link the issue it closes.
closing = body.scan(/\b(?:close[sd]?|fix(?:e[sd])?|resolve[sd]?)\s*:?[ \t]+#(\d+)\b/i).flatten.map(&:to_i).uniq
errors << "PR body must link at least one issue with a closing keyword" if closing.empty?

if lightweight
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

  # The head SHA in the body is optional (the gate already has the real head);
  # when present it must still match, which preserves the anti-stale check.
  reported_head = body[/^Current head SHA:\s*`?([0-9a-f]{40})`?\s*$/i, 1]
  errors << "reported head SHA does not match the pull request head" if reported_head && head_sha && reported_head != head_sha
  errors << "base and head SHA are identical" if base_sha && head_sha && base_sha == head_sha
end

errors << "pull request template still contains unresolved HTML placeholders" if body.include?("<!--")

if errors.empty?
  mode = lightweight ? " (lightweight)" : ""
  puts "Verdify pull request policy passed#{mode} for issue(s): #{closing.map { |n| "##{n}" }.join(', ')}"
  exit 0
end
warn "Verdify pull request policy failed:"
errors.each { |error| warn "  - #{error}" }
exit 1
