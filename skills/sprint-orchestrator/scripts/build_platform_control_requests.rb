#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "pathname"
require "time"
require "yaml"

options = {
  repo: Dir.pwd,
  runbook: nil,
  output_dir: nil,
  status: "proposed",
  policy_decision: "not_evaluated",
  approved_by: nil,
  approved_at: nil,
  mutation_level: "dev_write"
}

OptionParser.new do |parser|
  parser.banner = "Usage: build_platform_control_requests.rb --repo PATH --runbook PATH [options]"
  parser.on("--repo PATH", "Target repository root") { |value| options[:repo] = value }
  parser.on("--runbook PATH", "Sprint execution runbook path") { |value| options[:runbook] = value }
  parser.on("--output-dir PATH", "Directory for control request files") { |value| options[:output_dir] = value }
  parser.on("--status STATUS", "Request status, usually proposed or authorized") { |value| options[:status] = value }
  parser.on("--policy-decision DECISION", "Policy decision, usually not_evaluated or allow") { |value| options[:policy_decision] = value }
  parser.on("--approved-by NAME", "Approver when creating authorized requests") { |value| options[:approved_by] = value }
  parser.on("--approved-at TIME", "Approval timestamp when authorized") { |value| options[:approved_at] = value }
  parser.on("--mutation-level LEVEL", "Mutation level for generated requests") { |value| options[:mutation_level] = value }
  parser.on("-h", "--help") { puts parser; exit 0 }
end.parse!

abort "--runbook is required" if options[:runbook].to_s.empty?

repo = Pathname.new(options[:repo]).expand_path
runbook_path = Pathname.new(options[:runbook]).expand_path
abort "repo does not exist: #{repo}" unless repo.directory?
abort "runbook does not exist: #{runbook_path}" unless runbook_path.file?

def load_yaml(path)
  YAML.safe_load(path.read, permitted_classes: [], aliases: false)
end

def rel(path, root)
  Pathname.new(path).expand_path.relative_path_from(root).to_s
rescue ArgumentError
  path.to_s
end

def slug(value)
  value.to_s.downcase.gsub(/[^a-z0-9-]+/, "-").gsub(/\A-+|-+\z/, "").gsub(/-+/, "-")
end

def compact_refs(*values)
  values.flatten.compact.reject { |value| value.to_s.empty? }.uniq
end

def protected_mutation?(mutation_level)
  %w[protected_write production_write].include?(mutation_level.to_s)
end

def controller_api_ref(runbook)
  explicit = runbook.dig("platform", "api_ref")
  return explicit unless explicit.to_s.empty?

  repository = runbook["repository"].to_s
  return "POST /api/repos/<owner>/<repo>/agents" unless repository.include?("/")

  owner, name = repository.split("/", 2)
  "POST /api/repos/#{owner}/#{name}/agents"
end

runbook = load_yaml(runbook_path)
abort "runbook is not a SprintExecutionRunbook" unless runbook["kind"] == "SprintExecutionRunbook"

default_dir = runbook_path.dirname.join("control-requests")
output_dir = options[:output_dir] ? Pathname.new(options[:output_dir]).expand_path : default_dir
output_dir.mkpath

requested_at = Time.now.utc.iso8601
human_gate_required = protected_mutation?(options[:mutation_level])
review_decision = if options[:approved_by]
                    "approved"
                  elsif human_gate_required
                    "pending"
                  else
                    "not_required"
                  end
approved_at = options[:approved_at] || (options[:approved_by] ? requested_at : nil)
operation_id = "add_worktree_agent"
api_ref = controller_api_ref(runbook)

Array(runbook["lanes"]).each do |lane|
  lane_id = lane["lane_id"]
  request_id = "apc-#{slug(runbook['sprint_id'])}-#{slug(lane_id)}-add-worktree-agent"
  target_path = lane.dig("platform_session", "create_operation_ref")
  output_path = target_path ? repo.join(target_path) : output_dir.join("#{lane_id}-add-worktree-agent.yaml")
  output_path.dirname.mkpath

  request = {
    "schema_ref" => "agent-platform-control-request.schema.yaml",
    "kind" => "AgentPlatformControlRequest",
    "schema_version" => "1.0",
    "request_id" => request_id,
    "status" => options[:status],
    "requested_at" => requested_at,
    "requester" => {
      "actor" => runbook.dig("controller", "owner") || "sprint-orchestrator",
      "role" => "orchestrator",
      "session_id" => runbook.dig("controller", "session_id"),
      "reason" => "Add the approved lane worker as an Agent Platform worktree agent."
    },
    "operation" => {
      "surface" => "worktree",
      "operation_id" => operation_id,
      "method" => "POST",
      "tool_name" => operation_id,
      "api_ref" => api_ref,
      "mutation_level" => options[:mutation_level],
      "idempotency_key" => "#{runbook['runbook_id']}:#{lane_id}:add-worktree-agent"
    },
    "target" => {
      "repository" => runbook["repository"],
      "environment" => runbook.dig("deployment", "target_environment"),
      "namespace" => runbook.dig("deployment", "namespace"),
      "branch" => lane["branch"],
      "issue_ids" => Array(lane["issue_ids"]),
      "lane_ids" => [lane_id],
      "pr_refs" => [],
      "deployment_ids" => []
    },
    "authorization" => {
      "auth_mode" => runbook.dig("platform", "auth_mode") || "mcp_session",
      "subject" => runbook.dig("controller", "owner"),
      "scopes" => ["agent-platform:worktree-agents:add"],
      "service_account" => nil,
      "subject_access_review_required" => false,
      "approved_by" => options[:approved_by],
      "approved_at" => approved_at
    },
    "policy" => {
      "decision" => options[:policy_decision],
      "policy_decision_id" => nil,
      "rules" => ["Use add_worktree_agent once per dependency-ready approved lane."],
      "constraints" => [
        "Do not launch local workers as an unstated fallback.",
        "Do not mutate protected or production environments from the worker session."
      ],
      "reason" => "Prepared from the approved sprint execution runbook."
    },
    "inputs" => {
      "artifact_refs" => compact_refs(
        rel(runbook_path, repo),
        lane["contract_path"],
        lane.dig("prompt", "prompt_path"),
        lane.dig("prompt", "manifest_path"),
        runbook.dig("prerequisites", "wave_release_plan"),
        runbook.dig("prerequisites", "platform_readiness"),
        runbook.dig("ledger", "session_ledger_path")
      ),
      "evidence_refs" => [],
      "parameters_summary" => "Call add_worktree_agent for lane #{lane_id} on branch #{lane['branch']} using #{lane.dig('platform_session', 'executor')}.",
      "redacted_payload_ref" => nil
    },
    "expected_effects" => {
      "state_changes" => [
        "One Agent Platform worktree agent is added for lane #{lane_id}.",
        "The lane lease, prompt, contract, branch, and issue refs are bound to the platform agent.",
        "Agent result refs can be written back to the runbook and session ledger."
      ],
      "external_refs_expected" => ["Agent Platform worktree agent ID", "GitHub PR/check refs"],
      "rollback_or_recovery" => "If add_worktree_agent fails or identity is ambiguous, mark the lane blocked and route to platform-readiness or a gate."
    },
    "result" => {
      "status" => "not_started",
      "executed_at" => nil,
      "executor" => nil,
      "observed_refs" => [],
      "errors" => []
    },
    "review" => {
      "human_gate_required" => human_gate_required,
      "reviewers" => compact_refs(options[:approved_by]),
      "decision" => review_decision,
      "decided_at" => approved_at
    },
    "handoff" => {
      "next_skill" => "sprint-orchestrator",
      "next_mode" => "platform-dispatch",
      "reason" => "Prepared control request records the exact add_worktree_agent operation for dispatch."
    }
  }

  rendered = YAML.dump(request).gsub(/[ \t]+$/, "")
  output_path.write(rendered)
  puts output_path
end
