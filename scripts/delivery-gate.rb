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
  bootstrap: false
}

OptionParser.new do |parser|
  parser.banner = "Usage: ruby scripts/delivery-gate.rb --event EVENT.json --repo CANDIDATE [--reviews REVIEWS.json]"
  parser.on("--event PATH") { |value| options[:event] = value }
  parser.on("--repo PATH") { |value| options[:repo] = value }
  parser.on("--reviews PATH") { |value| options[:reviews] = value }
  parser.on("--config PATH") { |value| options[:config] = value }
  parser.on("--bootstrap") { options[:bootstrap] = true }
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

config = YAML.safe_load(File.read(options[:config]), permitted_classes: [], aliases: false)
flow = config.fetch("release_branch_flow")
development_branch = flow.fetch("development_branch")
release_branch = flow.fetch("release_branch")
expected_repository = flow.fetch("repository")
allowed_release_approvers = Array(flow.fetch("allowed_release_approvers")).map(&:downcase)
errors = []

errors << "delivery configuration must name dev and main" unless development_branch == "dev" && release_branch == "main"
errors << "delivery configuration must name both release owners" unless allowed_release_approvers.sort == %w[jrvallery jvallery]

if options[:bootstrap]
  errors << "--repo is required for bootstrap" if options[:repo].to_s.empty?
  if options[:repo] && !Pathname.new(options[:repo]).join("scripts/delivery-gate.rb").file?
    errors << "bootstrap repository does not contain scripts/delivery-gate.rb"
  end
elsif options[:event].to_s.empty? || options[:repo].to_s.empty?
  warn "--event and --repo are required unless --bootstrap is used"
  exit 2
else
  event = load_json(options[:event], "event")
  pull_request = event["pull_request"]
  if !pull_request.is_a?(Hash)
    errors << "delivery gate requires a pull request event"
  else
    base_ref = pull_request.dig("base", "ref").to_s
    head_ref = pull_request.dig("head", "ref").to_s
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
    elsif base_ref == release_branch
      unless head_ref == development_branch &&
             base_repository == expected_repository &&
             head_repository == expected_repository &&
             event_repository == expected_repository
        errors << "main critic gate accepts only the same-repository dev-to-main release route"
      end
      reviews = options[:reviews] ? load_json(options[:reviews], "reviews") : []
      latest = latest_effective_reviews(reviews)
      unresolved = latest.values.select { |review| review["state"].to_s.upcase == "CHANGES_REQUESTED" }
      unless unresolved.empty?
        errors << "an effective change-request review remains unresolved: #{unresolved.filter_map { |review| review.dig('user', 'login') }.sort.join(', ')}"
      end
      approval = latest.values.find do |review|
        login = review.dig("user", "login").to_s.downcase
        type = review.dig("user", "type").to_s
        allowed_release_approvers.include?(login) &&
          login != author &&
          type == "User" &&
          !login.end_with?("[bot]") &&
          review["state"].to_s.upcase == "APPROVED" &&
          review["commit_id"] == head_sha
      end
      errors << "main requires a current-head APPROVED review by jvallery or jrvallery other than the author" unless approval
    else
      errors << "delivery gate accepts only dev integration or main release pull requests"
    end
  end
end

if errors.empty?
  puts(options[:bootstrap] ? "Verdify delivery gate bootstrap passed." : "Verdify critic gate passed.")
  exit 0
end

warn "Verdify critic gate failed:"
errors.uniq.each { |error| warn "  - #{error}" }
exit 1
