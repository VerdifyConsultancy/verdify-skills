#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "optparse"
require "pathname"
require "time"
require "yaml"

options = {
  repo: Dir.pwd,
  sprint: nil,
  output: nil,
  controller_session_id: nil,
  controller_owner: "sprint-orchestrator",
  mcp_server: "in-pod-controller-mcp",
  api_ref: nil,
  executor: "agent-platform-worker",
  model: nil,
  effort: nil,
  poll_minutes: 5,
  heartbeat_minutes: 15,
  platform_readiness: ".agent-workflow/platform/platform-readiness.yaml"
}

OptionParser.new do |parser|
  parser.banner = "Usage: build_execution_runbook.rb --repo PATH --sprint ID [options]"
  parser.on("--repo PATH", "Target repository root") { |value| options[:repo] = value }
  parser.on("--sprint ID", "Sprint ID") { |value| options[:sprint] = value }
  parser.on("--output PATH", "Output runbook path") { |value| options[:output] = value }
  parser.on("--controller-session-id ID", "Controller session ID") { |value| options[:controller_session_id] = value }
  parser.on("--controller-owner NAME", "Controller owner/name") { |value| options[:controller_owner] = value }
  parser.on("--mcp-server NAME", "Agent Platform MCP server identity") { |value| options[:mcp_server] = value }
  parser.on("--api-ref REF", "Agent Platform API/MCP reference") { |value| options[:api_ref] = value }
  parser.on("--executor NAME", "Lane worker executor name") { |value| options[:executor] = value }
  parser.on("--model NAME", "Requested lane model") { |value| options[:model] = value }
  parser.on("--effort LEVEL", "Requested lane reasoning/effort level") { |value| options[:effort] = value }
  parser.on("--poll-minutes N", Integer, "Controller poll interval") { |value| options[:poll_minutes] = value }
  parser.on("--heartbeat-minutes N", Integer, "Worker heartbeat timeout") { |value| options[:heartbeat_minutes] = value }
  parser.on("--platform-readiness PATH", "Platform readiness artifact ref") { |value| options[:platform_readiness] = value }
  parser.on("-h", "--help") { puts parser; exit 0 }
end.parse!

abort "--sprint is required" if options[:sprint].to_s.empty?

repo = Pathname.new(options[:repo]).expand_path
abort "repo does not exist: #{repo}" unless repo.directory?

sprint_dir = repo.join(".agent-workflow/sprints", options[:sprint])
plan_path = sprint_dir.join("sprint-plan.yaml")
abort "sprint plan does not exist: #{plan_path}" unless plan_path.file?

def load_yaml(path)
  YAML.safe_load(path.read, permitted_classes: [], aliases: false)
end

def rel(path, root)
  Pathname.new(path).expand_path.relative_path_from(root).to_s
rescue ArgumentError
  path.to_s
end

def repo_path(root, artifact_path)
  value = artifact_path.to_s
  value = value.sub(%r{\A\.agent-workflow/}, ".agent-workflow/")
  root.join(value)
end

def lane_completed?(lane)
  lane["dependency_state"] == "complete" ||
    lane["status"] == "complete" ||
    lane.dig("platform_session", "status") == "complete"
end

def dependency_state_for(lane_id, dependency_order, completed_lane_ids)
  return "ready" if dependency_order.empty?
  return "complete" if completed_lane_ids.include?(lane_id)

  wave_index = dependency_order.index { |wave| wave.include?(lane_id) }
  return "ready" if wave_index.nil?

  first_open_wave = dependency_order.index { |wave| (wave - completed_lane_ids).any? }
  return "complete" if first_open_wave.nil?

  wave_index == first_open_wave ? "ready" : "waiting"
end

plan = load_yaml(plan_path)
abort "sprint plan is not a SprintPlan" unless plan["kind"] == "SprintPlan"

controller_session = options[:controller_session_id] || "controller-#{options[:sprint]}"
runbook_id = "exec-#{options[:sprint]}"
output_path = options[:output] ? Pathname.new(options[:output]).expand_path : sprint_dir.join("execution/sprint-execution-runbook.yaml")
output_path.dirname.mkpath
existing_runbook = output_path.file? ? load_yaml(output_path) : nil
existing_lanes = existing_runbook.is_a?(Hash) ? Array(existing_runbook["lanes"]) : []
completed_lane_ids = existing_lanes.select { |lane| lane_completed?(lane) }.map { |lane| lane["lane_id"].to_s }
dependency_order = Array(plan["dependency_order"]).map { |wave| Array(wave).map(&:to_s) }.reject(&:empty?)
api_ref = options[:api_ref] || "POST /api/repos/<owner>/<repo>/agents"

lane_records = Array(plan["lanes"]).map do |lane|
  contract_path = repo_path(repo, lane["contract_path"])
  contract_hash = contract_path.file? ? Digest::SHA256.file(contract_path).hexdigest : nil
  prompt_base = sprint_dir.join("prompts", "#{lane['lane_id']}.worker")
  dependency_state = dependency_state_for(lane["lane_id"].to_s, dependency_order, completed_lane_ids)
  {
    "lane_id" => lane["lane_id"],
    "issue_ids" => Array(lane["issue_ids"]),
    "contract_path" => lane["contract_path"],
    "branch" => lane["branch"],
    "owner" => lane["owner"] || "worker",
    "dependency_state" => dependency_state,
    "platform_session" => {
      "create_operation_ref" => ".agent-workflow/sprints/#{options[:sprint]}/execution/control-requests/#{lane['lane_id']}-add-worktree-agent.yaml",
      "session_id" => nil,
      "executor" => options[:executor],
      "model" => options[:model],
      "effort" => options[:effort],
      "status" => dependency_state == "complete" ? "complete" : "planned"
    },
    "prompt" => {
      "prompt_path" => rel("#{prompt_base}.md", repo),
      "manifest_path" => rel("#{prompt_base}.manifest.json", repo),
      "contract_hash" => contract_hash
    },
    "terminal" => {
      "tmux_session" => nil,
      "browser_terminal_url" => nil,
      "operator_attach_required" => false
    },
    "status" => dependency_state == "complete" ? "complete" : "planned"
  }
end

contracts = lane_records.map { |lane| lane["contract_path"] }
wave_path = sprint_dir.join("release/wave-release-plan.yaml")
wave = wave_path.file? ? load_yaml(wave_path) : nil
status = wave ? "ready" : "draft"
repository = plan.dig("github", "repository") || "local/#{repo.basename}"

runbook = {
  "schema_ref" => "sprint-execution-runbook.schema.yaml",
  "kind" => "SprintExecutionRunbook",
  "schema_version" => "1.0",
  "runbook_id" => runbook_id,
  "status" => status,
  "sprint_id" => options[:sprint],
  "wave_id" => wave ? wave["wave_id"] : nil,
  "repository" => repository,
  "prepared_at" => Time.now.utc.iso8601,
  "controller" => {
    "session_id" => controller_session,
    "owner" => options[:controller_owner],
    "authority" => "Coordinate Agent Platform worktree-agent dispatch, answer delegated lane questions, reconcile CI/CD, and stop at protected gates.",
    "interfaces" => %w[agent_platform_mcp github ci gitops telemetry],
    "poll_interval_minutes" => options[:poll_minutes],
    "delegation_policy" => "Full delegated authority inside approved lane contracts; protected decisions remain gated."
  },
  "prerequisites" => {
    "approved_sprint_plan" => rel(plan_path, repo),
    "approved_lane_contracts" => contracts,
    "wave_release_plan" => wave_path.file? ? rel(wave_path, repo) : nil,
    "platform_readiness" => options[:platform_readiness],
    "open_blockers" => []
  },
  "platform" => {
    "mcp_server" => options[:mcp_server],
    "api_ref" => api_ref,
    "auth_mode" => "mcp_session",
    "required_tools" => [
      { "name" => "add_worktree_agent", "purpose" => "Dispatch one approved lane worker through the in-pod Agent Platform controller MCP surface.", "required" => true }
    ],
    "terminal_access" => {
      "mode" => "none",
      "operator_visible" => false,
      "attach_refs" => []
    },
    "fallback_policy" => "If add_worktree_agent is unavailable, stop and route to platform-readiness or a gate instead of launching local workers ad hoc."
  },
  "cadence" => {
    "poll_interval_minutes" => options[:poll_minutes],
    "heartbeat_timeout_minutes" => options[:heartbeat_minutes],
    "loop_until" => [
      "All required lanes have closeout artifacts.",
      "Independent critics approve current heads.",
      "Review packet is complete with exact revision, CI, deployment, telemetry, rollback, and questions.",
      "Deployment verification and outcome review are ready for the next role."
    ]
  },
  "lanes" => lane_records,
  "coordination" => {
    "poll_steps" => [
      "Refresh GitHub, lease, session, PR, check, and deployment state.",
      "Observe lane progress through GitHub, PR checks, leases, closeout artifacts, and recorded Agent Platform result refs.",
      "Capture questions, blockers, closeout, and coordination requests from durable lane evidence.",
      "Answer delegated questions or open gates for protected decisions.",
      "Record controller and session-ledger events, then update sprint status."
    ],
    "controller_responses" => [
      "Answer contract-scoped worker questions.",
      "Dispatch only dependency-ready lanes with no active worker lease or recorded worktree-agent result.",
      "Route scope changes to sprint-planning or architecture-contracts.",
      "Route closeout to independent-critic and approved lanes to review-inbox."
    ],
    "coordination_request_policy" => "Resolve only within approved lane contracts and delegation; route protected changes to gates.",
    "escalation_paths" => []
  },
  "ci_cd" => {
    "required_checks" => Array(wave&.dig("github", "required_checks") || []),
    "workflows" => Array(wave&.dig("ci", "workflows")).map { |item| item["name"] }.compact,
    "merge_policy" => "Merge or queue only after critic approval, review packet readiness, and required checks.",
    "deployment_trigger" => "Trigger review deployment only from approved release plan and authorized environment policy.",
    "evidence_refs" => []
  },
  "deployment" => {
    "target_environment" => Array(wave&.dig("environments")).find { |env| env["required"] }&.dig("name"),
    "namespace" => Array(wave&.dig("environments")).find { |env| env["required"] }&.dig("namespace"),
    "strategy" => wave&.dig("deployment_strategy", "type") || "Follow the approved wave release plan.",
    "approval_required" => wave&.dig("github", "environment_protection_required") || false,
    "rollout_refs" => Array(wave&.dig("gitops", "desired_state_refs") || []),
    "rollback_refs" => Array(wave&.dig("rollback", "validation_steps") || [])
  },
  "review" => {
    "review_packet_path" => ".agent-workflow/sprints/#{options[:sprint]}/review/review-inbox-packet.yaml",
    "human_review_trigger" => "Review packet complete with exact revision, checks, deployment evidence, telemetry, rollback, and open questions.",
    "reviewer_visibility" => []
  },
  "ledger" => {
    "controller_state_path" => ".agent-workflow/controller/controller-state.yaml",
    "session_ledger_path" => ".agent-workflow/controller/session-ledger.yaml",
    "required_events" => %w[lane_dispatched prompt_compiled worker_status worker_closeout critic_reviewed review_packet_created ci_observed deployment_observed]
  },
  "stop_conditions" => [
    "Agent Platform add_worktree_agent operation identity is missing or unavailable.",
    "A lane session, issue, branch, PR, lease, or contract identity conflicts.",
    "A worker asks for protected production, schema, security, migration, or destructive authority.",
    "Required CI/CD, review, deployment, telemetry, or rollback evidence cannot be obtained."
  ],
  "handoff" => {
    "next_skill" => "sprint-orchestrator",
    "next_mode" => "platform-dispatch",
    "reason" => "Dispatch dependency-ready lane workers through add_worktree_agent and supervise execution from GitHub and durable evidence."
  }
}

rendered = YAML.dump(runbook).gsub(/[ \t]+$/, "")
output_path.write(rendered)
puts output_path
