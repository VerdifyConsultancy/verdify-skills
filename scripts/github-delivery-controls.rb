#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "net/http"
require "optparse"
require "pathname"
require "time"
require "uri"
require "yaml"

ROOT = Pathname.new(File.expand_path("..", __dir__))

class DeliveryControlError < StandardError; end

class MockBranchProtectionApi
  def initialize(root:, repository:)
    @root = Pathname.new(root).expand_path.join(repository.tr("/", "__"))
  end

  def get(branch)
    path = branch_path(branch)
    path.file? ? JSON.parse(path.read) : nil
  end

  def put(branch, payload)
    path = branch_path(branch)
    FileUtils.mkdir_p(path.dirname)
    path.write(JSON.pretty_generate(payload) + "\n")
    get(branch)
  end

  def delete(branch)
    FileUtils.rm_f(branch_path(branch))
    nil
  end

  private

  def branch_path(branch)
    @root.join("#{branch}.json")
  end
end

class GithubBranchProtectionApi
  def initialize(api_base:, repository:, token:)
    raise DeliveryControlError, "GitHub token is required for live API access" if token.to_s.empty?

    @api_base = URI(api_base)
    @repository = repository
    @token = token
  end

  def get(branch)
    response = request(Net::HTTP::Get, branch)
    return nil if response.code.to_i == 404

    parse_success(response)
  end

  def put(branch, payload)
    response = request(Net::HTTP::Put, branch, payload)
    parse_success(response)
  end

  def delete(branch)
    response = request(Net::HTTP::Delete, branch)
    return nil if [204, 404].include?(response.code.to_i)

    parse_success(response)
  end

  private

  def endpoint(branch)
    base_path = @api_base.path.sub(%r{/\z}, "")
    encoded_branch = URI.encode_www_form_component(branch)
    "#{base_path}/repos/#{@repository}/branches/#{encoded_branch}/protection"
  end

  def request(type, branch, payload = nil)
    request = type.new(endpoint(branch))
    request["Accept"] = "application/vnd.github+json"
    request["Authorization"] = "Bearer #{@token}"
    request["X-GitHub-Api-Version"] = "2022-11-28"
    if payload
      request["Content-Type"] = "application/json"
      request.body = JSON.generate(payload)
    end
    Net::HTTP.start(@api_base.host, @api_base.port, use_ssl: @api_base.scheme == "https") do |http|
      http.request(request)
    end
  end

  def parse_success(response)
    unless response.code.to_i.between?(200, 299)
      raise DeliveryControlError, "GitHub API returned #{response.code}: #{response.body}"
    end
    response.body.to_s.empty? ? nil : JSON.parse(response.body)
  rescue JSON::ParserError => e
    raise DeliveryControlError, "GitHub API returned invalid JSON: #{e.message}"
  end
end

def enabled(value)
  value.is_a?(Hash) ? value["enabled"] == true : value == true
end

def normalized_protection(document)
  return nil if document.nil?

  status = document["required_status_checks"] || {}
  contexts = Array(status["contexts"])
  contexts += Array(status["checks"]).filter_map { |check| check["context"] }
  reviews = document["required_pull_request_reviews"] || {}
  {
    "required_status_checks" => {
      "strict" => status["strict"] == true,
      "contexts" => contexts.uniq.sort
    },
    "enforce_admins" => enabled(document["enforce_admins"]),
    "required_pull_request_reviews" => {
      "dismiss_stale_reviews" => reviews["dismiss_stale_reviews"] == true,
      "require_code_owner_reviews" => reviews["require_code_owner_reviews"] == true,
      "required_approving_review_count" => reviews["required_approving_review_count"].to_i,
      "require_last_push_approval" => reviews["require_last_push_approval"] == true
    },
    "restrictions" => document["restrictions"],
    "required_conversation_resolution" => enabled(document["required_conversation_resolution"]),
    "allow_force_pushes" => enabled(document["allow_force_pushes"]),
    "allow_deletions" => enabled(document["allow_deletions"])
  }
end

options = {
  config: ROOT.join("config/github-delivery-controls.yaml").to_s,
  phase: nil,
  mode: "dry-run",
  repository: nil,
  confirm_repository: nil,
  snapshot: nil,
  mock_api: nil,
  api_base: "https://api.github.com",
  token_env: "GH_TOKEN"
}

OptionParser.new do |parser|
  parser.banner = "Usage: ruby scripts/github-delivery-controls.rb --phase PHASE --mode dry-run|apply|verify|rollback"
  parser.on("--config PATH") { |value| options[:config] = value }
  parser.on("--phase PHASE") { |value| options[:phase] = value }
  parser.on("--mode MODE") { |value| options[:mode] = value }
  parser.on("--repository OWNER/REPO") { |value| options[:repository] = value }
  parser.on("--confirm-repository OWNER/REPO") { |value| options[:confirm_repository] = value }
  parser.on("--snapshot PATH") { |value| options[:snapshot] = value }
  parser.on("--mock-api DIRECTORY") { |value| options[:mock_api] = value }
  parser.on("--api-base URL") { |value| options[:api_base] = value }
  parser.on("--token-env NAME") { |value| options[:token_env] = value }
  parser.on("-h", "--help") { puts parser; exit 0 }
end.parse!

begin
  config = YAML.safe_load(File.read(options[:config]), permitted_classes: [], aliases: false)
  repository = options[:repository] || config.fetch("repository")
  raise DeliveryControlError, "repository must match declarative config" unless repository == config.fetch("repository")
  phase = options[:phase].to_s
  desired_by_branch = config.dig("phases", phase, "branches")
  raise DeliveryControlError, "unknown phase #{phase.inspect}" unless desired_by_branch.is_a?(Hash)
  mode = options[:mode]
  raise DeliveryControlError, "unsupported mode #{mode.inspect}" unless %w[dry-run apply verify rollback].include?(mode)
  if %w[apply rollback].include?(mode)
    unless options[:confirm_repository] == repository
      raise DeliveryControlError, "#{mode} requires --confirm-repository #{repository}"
    end
    raise DeliveryControlError, "#{mode} requires --snapshot PATH" if options[:snapshot].to_s.empty?
  end

  api = if options[:mock_api]
          MockBranchProtectionApi.new(root: options[:mock_api], repository: repository)
        else
          GithubBranchProtectionApi.new(
            api_base: options[:api_base],
            repository: repository,
            token: ENV[options[:token_env]]
          )
        end

  current_by_branch = desired_by_branch.keys.to_h { |branch| [branch, api.get(branch)] }
  if mode == "rollback"
    snapshot = JSON.parse(File.read(options[:snapshot]))
    raise DeliveryControlError, "snapshot repository mismatch" unless snapshot["repository"] == repository
    raise DeliveryControlError, "snapshot phase mismatch" unless snapshot["phase"] == phase
    snapshot.fetch("branches").each do |branch, entry|
      entry["present"] ? api.put(branch, entry.fetch("payload")) : api.delete(branch)
    end
    branches = snapshot.fetch("branches").map do |branch, entry|
      expected = entry["present"] ? normalized_protection(entry.fetch("payload")) : nil
      actual = normalized_protection(api.get(branch))
      { "branch" => branch, "changed" => normalized_protection(current_by_branch[branch]) != expected, "matches" => actual == expected, "current" => actual, "desired" => expected }
    end
    result = { "mode" => mode, "phase" => phase, "repository" => repository, "matches" => branches.all? { |item| item["matches"] }, "branches" => branches }
    puts JSON.pretty_generate(result)
    exit(result["matches"] ? 0 : 1)
  end

  desired_normalized = desired_by_branch.transform_values { |payload| normalized_protection(payload) }
  branches = desired_by_branch.map do |branch, desired|
    current = normalized_protection(current_by_branch[branch])
    target = desired_normalized.fetch(branch)
    { "branch" => branch, "changed" => current != target, "matches" => current == target, "current" => current, "desired" => target, "payload" => desired }
  end

  if mode == "apply"
    snapshot_path = Pathname.new(options[:snapshot]).expand_path
    unless snapshot_path.exist?
      snapshot = {
        "repository" => repository,
        "phase" => phase,
        "captured_at" => Time.now.utc.iso8601,
        "branches" => current_by_branch.transform_values do |document|
          { "present" => !document.nil?, "payload" => normalized_protection(document) }
        end
      }
      FileUtils.mkdir_p(snapshot_path.dirname)
      snapshot_path.write(JSON.pretty_generate(snapshot) + "\n")
    else
      existing_snapshot = JSON.parse(snapshot_path.read)
      unless existing_snapshot["repository"] == repository && existing_snapshot["phase"] == phase
        raise DeliveryControlError, "existing snapshot repository or phase mismatch"
      end
    end
    branches.each do |item|
      api.put(item["branch"], item["payload"]) if item["changed"]
      actual = normalized_protection(api.get(item["branch"]))
      item["matches"] = actual == item["desired"]
      item["current"] = actual
    end
  end

  branches.each { |item| item.delete("payload") }
  result = {
    "mode" => mode,
    "phase" => phase,
    "repository" => repository,
    "matches" => branches.all? { |item| item["matches"] },
    "branches" => branches
  }
  puts JSON.pretty_generate(result)
  exit(mode == "verify" || mode == "apply" ? (result["matches"] ? 0 : 1) : 0)
rescue DeliveryControlError, Errno::ENOENT, JSON::ParserError, Psych::Exception, KeyError => e
  warn "GitHub delivery controls failed: #{e.message}"
  exit 2
end
