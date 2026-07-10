#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

ruby - "$ROOT" "$TMP" <<'RUBY'
require "digest"
require "fileutils"
require "json"
require "open3"
require "yaml"

root, tmp = ARGV
require File.join(root, "lib/verdify")

def git(repo, *args)
  stdout, stderr, status = Open3.capture3("git", "-C", repo, *args)
  raise "git #{args.join(' ')} failed: #{stderr}" unless status.success?
  stdout.strip
end

def git_bytes(repo, *args)
  stdout, stderr, status = Open3.capture3("git", "-C", repo, *args)
  raise "git #{args.join(' ')} failed: #{stderr}" unless status.success?
  stdout
end

def run_gate(root, event, repo, reviews: nil, success: true, env: {})
  command = ["ruby", File.join(root, "scripts/delivery-gate.rb"), "--event", event, "--repo", repo]
  command.concat(["--reviews", reviews]) if reviews
  stdout, stderr, status = Open3.capture3(env, *command)
  if success && !status.success?
    raise "expected delivery gate success: #{stdout}\n#{stderr}"
  elsif !success && status.success?
    raise "expected delivery gate failure: #{stdout}\n#{stderr}"
  end
  stderr
end

def prepare_release_event(root, pulls, expected_head, success: true)
  stdout, stderr, status = Open3.capture3(
    "ruby", File.join(root, "scripts/delivery-gate.rb"),
    "--prepare-release-event", pulls,
    "--expected-head", expected_head
  )
  if success && !status.success?
    raise "expected release event preparation success: #{stdout}\n#{stderr}"
  elsif !success && status.success?
    raise "expected release event preparation failure: #{stdout}\n#{stderr}"
  end
  stdout
end

def build_chain(root, directory, critic_agent: "critic-agent", critic_session: "critic-session", outcome: "approve")
  FileUtils.mkdir_p(directory)
  git(directory, "init", "-q", "-b", "lane/test")
  git(directory, "config", "user.name", "Verdify Test")
  git(directory, "config", "user.email", "verdify-test@example.invalid")
  File.write(File.join(directory, "README.md"), "# fixture\n")
  File.write(File.join(directory, "package.json"), JSON.generate("name" => "@verdify/test", "version" => "9.9.9") + "\n")
  File.write(File.join(directory, "VERSION"), "9.9.9\n")
  git(directory, "add", ".")
  git(directory, "commit", "-qm", "baseline")
  baseline = git(directory, "rev-parse", "HEAD")

  sprint = ".agent-workflow/sprints/test-sprint"
  contract_rel = "#{sprint}/lanes/contracts/test-lane.contract.yaml"
  closeout_rel = "#{sprint}/lanes/closeout/test-lane.closeout.yaml"
  critic_rel = "#{sprint}/critic/test-lane.critic.yaml"
  [contract_rel, closeout_rel, critic_rel].each { |path| FileUtils.mkdir_p(File.dirname(File.join(directory, path))) }
  contract = Verdify::SchemaValidator.load_document(
    File.join(root, "examples/minimal-project/.agent-workflow/sprints/2026-06-22-a/lanes/contracts/issue-123-api.contract.yaml")
  )
  contract["sprint_id"] = "test-sprint"
  contract["lane_id"] = "test-lane"
  contract["issue_ids"] = [121]
  contract["baseline_sha"] = baseline
  contract["branch"] = "lane/test"
  contract["approval"] = { "status" => "approved", "approver" => "owner", "approved_at" => "2026-07-10T00:00:00Z" }
  File.write(File.join(directory, contract_rel), YAML.dump(contract))
  plan = Verdify::SchemaValidator.load_document(
    File.join(root, "examples/minimal-project/.agent-workflow/sprints/2026-06-22-a/sprint-plan.yaml")
  )
  plan["sprint_id"] = "test-sprint"
  plan["status"] = "approved"
  plan["baseline_sha"] = baseline
  plan["issue_ids"] = [121]
  plan["github"]["repository"] = "example/test"
  plan_lane = plan.fetch("lanes").first
  plan_lane["lane_id"] = "test-lane"
  plan_lane["issue_ids"] = [121]
  plan_lane["contract_path"] = contract_rel
  plan_lane["branch"] = "lane/test"
  plan.fetch("acceptance_criteria").each { |criterion| criterion["lane_ids"] = ["test-lane"] }
  plan.dig("review_plan", "user_stories_for_review").each do |story|
    story["issue_ids"] = [121]
    story["lane_ids"] = ["test-lane"]
  end
  plan["approval"] = { "status" => "approved", "approver" => "owner", "approved_at" => "2026-07-10T00:00:00Z" }
  File.write(File.join(directory, "#{sprint}/sprint-plan.yaml"), YAML.dump(plan))
  FileUtils.mkdir_p(File.join(directory, sprint, "release"))
  File.write(File.join(directory, "#{sprint}/release/wave-release-plan.yaml"), "kind: WaveReleasePlan\n")
  git(directory, "add", sprint)
  git(directory, "commit", "-qm", "dispatch")

  File.write(File.join(directory, "implementation.txt"), "implemented\n")
  git(directory, "add", "implementation.txt")
  git(directory, "commit", "-qm", "implementation")
  implementation = git(directory, "rev-parse", "HEAD")
  contract_path = File.join(directory, contract_rel)
  closeout_path = File.join(directory, closeout_rel)
  closeout = {
    "schema_ref" => "lane-closeout.schema.yaml", "kind" => "LaneCloseout", "schema_version" => "2.0",
    "sprint_id" => "test-sprint", "lane_id" => "test-lane", "status" => "ready_for_critic",
    "issue_ids" => [121], "pull_request" => 456, "baseline_sha" => baseline,
    "implementation_head_sha" => implementation, "validated_head_sha" => implementation,
    "contract_hash" => Digest::SHA256.file(contract_path).hexdigest, "changed_paths" => ["implementation.txt"],
    "validation_results" => [{ "id" => "test", "command" => "true", "exit_status" => 0, "result" => "passed", "executed_at" => "2026-07-10T00:01:00Z", "artifact" => nil }],
    "acceptance_evidence" => [{ "criterion_id" => "LANE-AC-01", "evidence_ids" => ["test"], "assessment" => "satisfied" }],
    "discovered_issues" => [], "residual_risks" => [], "worktree_clean" => true,
    "worker_agent" => "worker-agent", "worker_session_id" => "worker-session",
    "completed_at" => "2026-07-10T00:02:00Z", "limitations" => []
  }
  File.write(closeout_path, YAML.dump(closeout))
  git(directory, "add", closeout_rel)
  git(directory, "commit", "-qm", "evidence")
  evidence = git(directory, "rev-parse", "HEAD")

  critic = {
    "schema_ref" => "critic-report.schema.yaml", "kind" => "CriticReport", "schema_version" => "2.0",
    "sprint_id" => "test-sprint", "lane_id" => "test-lane", "pull_request" => 456,
    "worker_agent" => "worker-agent", "worker_session_id" => "worker-session", "critic_agent" => critic_agent,
    "implementation_head_sha" => implementation, "evidence_head_sha" => evidence, "reviewed_head_sha" => evidence,
    "closeout_path" => closeout_rel, "closeout_sha256" => Digest::SHA256.file(closeout_path).hexdigest,
    "critic_session_id" => critic_session, "review_worktree" => directory, "outcome" => outcome,
    "findings" => [], "acceptance_assessment" => [{ "criterion_id" => "LANE-AC-01", "assessment" => "satisfied", "evidence" => ["test"] }],
    "evidence_assessment" => ["exact chain"], "integration_risks" => [], "residual_risks" => [],
    "reviewed_at" => "2026-07-10T00:03:00Z"
  }
  File.write(File.join(directory, critic_rel), YAML.dump(critic))
  git(directory, "add", critic_rel)
  git(directory, "commit", "-qm", "critic report")
  {
    head: git(directory, "rev-parse", "HEAD"), contract: contract_rel,
    baseline: baseline, implementation: implementation, evidence: evidence,
    closeout: closeout_rel, critic: critic_rel
  }
end

def build_receipt_chain(root, directory)
  chain = build_chain(root, directory)
  sprint_id = "test-sprint"
  sprint_root = ".agent-workflow/sprints/#{sprint_id}"
  report = chain.fetch(:head)

  git(directory, "checkout", "-qb", "dev", chain.fetch(:baseline))
  git(directory, "merge", "--no-ff", "-qm", "merge lane PR", "lane/test")
  merge_sha = git(directory, "rev-parse", "HEAD")
  FileUtils.mkdir_p(File.join(directory, "schemas"))
  FileUtils.cp(File.join(root, "schemas/sprint-terminal-receipt.schema.yaml"), File.join(directory, "schemas/sprint-terminal-receipt.schema.yaml"))
  git(directory, "add", "schemas/sprint-terminal-receipt.schema.yaml")
  git(directory, "commit", "-qm", "activate terminal receipt")
  base = git(directory, "rev-parse", "HEAD")

  git(directory, "checkout", "-qb", "controller/#{sprint_id}", chain.fetch(:baseline))
  %W[
    #{sprint_root}/sprint-plan.yaml
    #{sprint_root}/release/wave-release-plan.yaml
    #{chain.fetch(:contract)}
    #{chain.fetch(:closeout)}
    #{chain.fetch(:critic)}
  ].each do |relative|
    destination = File.join(directory, relative)
    FileUtils.mkdir_p(File.dirname(destination))
    File.binwrite(destination, git_bytes(directory, "show", "#{report}:#{relative}"))
  end
  git(directory, "add", sprint_root)
  git(directory, "commit", "-qm", "assemble controller evidence")

  packet_path = "#{sprint_root}/review/review-inbox-packet.yaml"
  packet = Verdify::SchemaValidator.load_document(
    File.join(root, "examples/minimal-project/.agent-workflow/sprints/2026-06-22-a/review/review-inbox-packet.yaml")
  )
  packet["status"] = "ready"
  packet["scope"]["sprint_id"] = sprint_id
  packet["scope"]["lane_ids"] = ["test-lane"]
  packet["scope"]["issue_ids"] = [121]
  packet["traceability"]["repository"] = "example/test"
  packet["traceability"]["base_ref"] = "dev"
  packet["traceability"]["head_ref"] = "controller/#{sprint_id}"
  packet["traceability"]["review_submissions"] = [{
    "pull_request" => 456, "review_submission_head_sha" => report,
    "reviewer_login" => "critic-agent", "reviewer_id" => 1
  }]
  packet.fetch("pull_requests").first["identifier"] = "#456"
  packet["evidence_completeness"]["verdict"] = "complete"
  packet["evidence_completeness"]["missing_required"] = []
  packet["evidence_completeness"]["blockers"] = []
  packet["security"]["unresolved_findings"] = []
  packet["recommendation"]["outcome"] = "approve"
  FileUtils.mkdir_p(File.dirname(File.join(directory, packet_path)))
  File.write(File.join(directory, packet_path), YAML.dump(packet))
  git(directory, "add", packet_path)
  git(directory, "commit", "-qm", "packet P")

  release_path = "#{sprint_root}/release/release-verification.yaml"
  release = Verdify::SchemaValidator.load_document(
    File.join(root, "examples/minimal-project/.agent-workflow/sprints/2026-06-22-a/release/release-verification.yaml")
  )
  release["sprint_id"] = sprint_id
  release["integrated_sha"] = base
  release["deployment"]["observed_revision"] = base
  File.write(File.join(directory, release_path), YAML.dump(release))
  git(directory, "add", release_path)
  git(directory, "commit", "-qm", "release R")

  outcome_path = "#{sprint_root}/outcome/outcome-review.yaml"
  outcome = Verdify::SchemaValidator.load_document(
    File.join(root, "examples/minimal-project/.agent-workflow/sprints/2026-06-22-a/outcome/outcome-review.yaml")
  )
  outcome["sprint_id"] = sprint_id
  FileUtils.mkdir_p(File.dirname(File.join(directory, outcome_path)))
  File.write(File.join(directory, outcome_path), YAML.dump(outcome))
  git(directory, "add", outcome_path)
  git(directory, "commit", "-qm", "outcome O")

  git(directory, "checkout", "-qb", "receipt/#{sprint_id}/#{base[0, 12]}", base)
  pull = {
    "number" => 456, "head_sha" => report, "head_ref" => "lane/test", "base_ref" => "dev",
    "state" => "closed", "merged" => true, "merge_commit_sha" => merge_sha
  }
  checks = Verdify::SprintTerminalReceipt::REQUIRED_CHECKS.map.with_index do |(name, workflow), index|
    {
      "id" => index + 1, "name" => name, "status" => "completed", "conclusion" => "success",
      "app_slug" => "github-actions", "workflow_path" => workflow, "workflow_event" => "pull_request",
      "workflow_head_sha" => report, "created_at" => nil, "started_at" => "2026-07-10T00:00:01Z",
      "completed_at" => "2026-07-10T00:00:02Z"
    }
  end
  validator = Verdify::SprintTerminalReceipt.new(
    repo: directory, pull_request_loader: ->(_number) { pull }, check_run_loader: ->(_sha) { checks }
  )
  validator.write!(
    sprint_id: sprint_id, controller_ref: "controller/#{sprint_id}", receipt_base_sha: base,
    mode: "normal", generator: "policy-integration-test"
  )
  git(directory, "add", *Verdify::SprintTerminalReceipt.paths(sprint_id).values)
  git(directory, "commit", "-qm", "terminal receipt")
  { base: base, head: git(directory, "rev-parse", "HEAD"), report: report, merge: merge_sha, checks: checks }
end

def event(path, head:, body:, base: "dev", base_sha: "b" * 40, source: "lane/test", author: "worker", base_repo: "VerdifyConsultancy/verdify-skills", head_repo: "VerdifyConsultancy/verdify-skills")
  repository = { "full_name" => "VerdifyConsultancy/verdify-skills" }
  payload = {
    "number" => 456,
    "repository" => repository,
    "pull_request" => {
      "number" => 456, "state" => "open", "body" => body, "user" => { "login" => author },
      "base" => { "ref" => base, "sha" => base_sha, "repo" => { "full_name" => base_repo } },
      "head" => { "ref" => source, "sha" => head, "repo" => { "full_name" => head_repo } }
    }
  }
  File.write(path, JSON.pretty_generate(payload))
end

valid_repo = File.join(tmp, "valid")
chain = build_chain(root, valid_repo)
body = "## Lane contract\n\n- Lane: `test-lane`\n- Contract: `#{chain[:contract]}`\n"
dev_event = File.join(tmp, "dev.json")
event(dev_event, head: chain[:head], body: body)
run_gate(root, dev_event, valid_repo)

receipt_body = "<!-- verdify-terminal-receipt:test-sprint:#{'b' * 40} -->\n"
event(dev_event, head: chain[:head], body: receipt_body, source: "receipt/test-sprint/#{('b' * 40)[0, 12]}")
receipt_error = run_gate(root, dev_event, valid_repo, success: false)
raise "incomplete receipt transaction was not rejected" unless receipt_error.include?("marker and sprint set") || receipt_error.include?("mixed or incomplete paths")
event(dev_event, head: chain[:head], body: body)

# One fully valid terminal receipt transaction must cross both script entrypoints.
# Only the external GitHub API evidence is replaced; the receipt generator,
# protected-base reconstruction, path policy, and both gates run unmodified.
receipt_repo = File.join(tmp, "receipt")
receipt = build_receipt_chain(root, receipt_repo)
github_mock = File.join(tmp, "terminal-github-mock.rb")
File.write(github_mock, <<~'MOCK')
  require ENV.fetch("VERDIFY_LIB")
  module Verdify
    class GitRepository
      def github_terminal_pull_request_evidence(number)
        {
          "number" => Integer(number), "head_sha" => ENV.fetch("TERMINAL_REPORT_SHA"),
          "head_ref" => "lane/test", "base_ref" => "dev", "state" => "closed",
          "merged" => true, "merge_commit_sha" => ENV.fetch("TERMINAL_MERGE_SHA")
        }
      end

      def github_check_run_evidence(ref)
        SprintTerminalReceipt::REQUIRED_CHECKS.map.with_index do |(name, workflow), index|
          {
            "id" => index + 1, "name" => name, "status" => "completed", "conclusion" => "success",
            "app_slug" => "github-actions", "workflow_path" => workflow, "workflow_event" => "pull_request",
            "workflow_head_sha" => ref, "created_at" => nil, "started_at" => "2026-07-10T00:00:01Z",
            "completed_at" => "2026-07-10T00:00:02Z"
          }
        end
      end
    end
  end
MOCK
receipt_env = {
  "RUBYOPT" => "-r#{github_mock}", "VERDIFY_LIB" => File.join(root, "lib/verdify"),
  "TERMINAL_REPORT_SHA" => receipt.fetch(:report), "TERMINAL_MERGE_SHA" => receipt.fetch(:merge)
}
receipt_body = <<~BODY
  <!-- verdify-terminal-receipt:test-sprint:#{receipt.fetch(:base)} -->

  Closes #135
BODY
event(
  dev_event, head: receipt.fetch(:head), body: receipt_body, base_sha: receipt.fetch(:base),
  source: "receipt/test-sprint/#{receipt.fetch(:base)[0, 12]}"
)
run_gate(root, dev_event, receipt_repo, env: receipt_env)
stdout, stderr, status = Open3.capture3(
  receipt_env, "ruby", File.join(root, "scripts/pr-policy.rb"), "--event", dev_event, "--repo", receipt_repo
)
raise "valid receipt PR policy failed: #{stdout}\n#{stderr}" unless status.success?
event(dev_event, head: chain[:head], body: body)

File.write(File.join(valid_repo, "post-report.txt"), "stale\n")
git(valid_repo, "add", "post-report.txt")
git(valid_repo, "commit", "-qm", "post-report change")
stale_head = git(valid_repo, "rev-parse", "HEAD")
event(dev_event, head: stale_head, body: body)
raise "stale report was not rejected" unless run_gate(root, dev_event, valid_repo, success: false).include?("critic report head")
git(valid_repo, "reset", "-q", "--hard", chain[:head])

self_repo = File.join(tmp, "self")
self_chain = build_chain(root, self_repo, critic_agent: "worker-agent")
event(dev_event, head: self_chain[:head], body: "- Lane: `test-lane`\n- Contract: `#{self_chain[:contract]}`\n")
raise "self critic was not rejected" unless run_gate(root, dev_event, self_repo, success: false).include?("critic agent must differ")

reject_repo = File.join(tmp, "reject")
reject_chain = build_chain(root, reject_repo, outcome: "request_fixes")
event(dev_event, head: reject_chain[:head], body: "- Lane: `test-lane`\n- Contract: `#{reject_chain[:contract]}`\n")
raise "non-approving critic was not rejected" unless run_gate(root, dev_event, reject_repo, success: false).include?("critic outcome")

release_event = File.join(tmp, "release.json")
release_body = <<~BODY
  <!-- verdify-release-candidate:@verdify/test@9.9.9 -->

  ## Backlog issue

  Closes #121

  ## Release candidate

  Promote dev to main.

  ## Version

  - VERSION: `9.9.9`
  - Package: `@verdify/test@9.9.9`

  ## Evidence

  Current head SHA: `#{chain[:head]}`

  ## Risk and rollback

  Restore the prior protected head.
BODY
event(release_event, head: chain[:head], body: release_body, base: "main", source: "dev", author: "jrvallery")
release_pull = JSON.parse(File.read(release_event)).fetch("pull_request")
pulls = File.join(tmp, "open-pulls.json")
File.write(pulls, JSON.generate([release_pull]))
push_event = File.join(tmp, "push-release-event.json")
File.write(push_event, prepare_release_event(root, pulls, chain[:head]))
stdout, stderr, status = Open3.capture3(
  "ruby", File.join(root, "scripts/pr-policy.rb"),
  "--event", push_event,
  "--repo", valid_repo
)
raise "push delivery-policy failed: #{stdout}\n#{stderr}" unless status.success?
reviews = File.join(tmp, "reviews.json")
File.write(reviews, "[]\n")
run_gate(root, push_event, valid_repo, reviews: reviews, success: false)
File.write(reviews, JSON.generate([{ "id" => 1, "state" => "APPROVED", "commit_id" => chain[:head], "submitted_at" => "2026-07-10T01:00:00Z", "user" => { "login" => "jvallery", "id" => 3_673_164, "type" => "User" } }]))
run_gate(root, push_event, valid_repo, reviews: reviews)

File.write(pulls, "[]\n")
prepare_release_event(root, pulls, chain[:head], success: false)
wrong_route = Marshal.load(Marshal.dump(release_pull))
wrong_route["head"]["ref"] = "feature"
File.write(pulls, JSON.generate([wrong_route]))
prepare_release_event(root, pulls, chain[:head], success: false)
duplicate = Marshal.load(Marshal.dump(release_pull))
duplicate["number"] = 457
File.write(pulls, JSON.generate([release_pull, duplicate]))
prepare_release_event(root, pulls, chain[:head], success: false)

File.write(reviews, JSON.generate([{ "id" => 1, "state" => "APPROVED", "commit_id" => "a" * 40, "submitted_at" => "2026-07-10T01:00:00Z", "user" => { "login" => "jvallery", "type" => "User" } }]))
run_gate(root, push_event, valid_repo, reviews: reviews, success: false)
File.write(reviews, JSON.generate([{ "id" => 1, "state" => "APPROVED", "commit_id" => chain[:head], "submitted_at" => "2026-07-10T01:00:00Z", "user" => { "login" => "jrvallery", "type" => "User" } }]))
run_gate(root, push_event, valid_repo, reviews: reviews, success: false)
File.write(reviews, JSON.generate([{ "id" => 1, "state" => "APPROVED", "commit_id" => chain[:head], "submitted_at" => "2026-07-10T01:00:00Z", "user" => { "login" => "jvallery", "type" => "Bot" } }]))
run_gate(root, push_event, valid_repo, reviews: reviews, success: false)
File.write(reviews, JSON.generate([
  { "id" => 1, "state" => "APPROVED", "commit_id" => chain[:head], "submitted_at" => "2026-07-10T01:00:00Z", "user" => { "login" => "jvallery", "type" => "User" } },
  { "id" => 2, "state" => "CHANGES_REQUESTED", "commit_id" => chain[:head], "submitted_at" => "2026-07-10T01:01:00Z", "user" => { "login" => "security-reviewer", "type" => "User" } }
]))
raise "unresolved change request was not rejected" unless run_gate(root, push_event, valid_repo, reviews: reviews, success: false).include?("change-request")

event(release_event, head: chain[:head], body: "release", base: "main", source: "dev", author: "jrvallery", head_repo: "attacker/fork")
run_gate(root, release_event, valid_repo, reviews: reviews, success: false)
RUBY

echo "Delivery gate tests passed."
