#!/usr/bin/env ruby
# frozen_string_literal: true

require "minitest/autorun"
require "fileutils"
require "open3"
require "tmpdir"
require "yaml"
require_relative "../lib/verdify"
require_relative "../scripts/validate-repo"
require_relative "test_lane_qr_schemarefs"

Dir[File.join(__dir__, "test_*.rb")].sort.each do |path|
  next if File.expand_path(path) == File.expand_path(__FILE__)

  require path
end

class SchemaValidatorTest < Minitest::Test
  def validator
    Verdify::SchemaValidator.new
  end

  def test_rejects_missing_required_and_unknown_properties
    schema = {
      "type" => "object",
      "additionalProperties" => false,
      "required" => ["name"],
      "properties" => { "name" => { "type" => "string" } }
    }
    errors = validator.validate({ "extra" => true }, schema)
    assert errors.any? { |e| e.include?("missing required property") }
    assert errors.any? { |e| e.include?("unexpected property") }
  end

  def test_checks_array_uniqueness_and_patterns
    schema = {
      "type" => "array",
      "uniqueItems" => true,
      "items" => { "type" => "string", "pattern" => "^[a-z]+$" }
    }
    errors = validator.validate(["valid", "valid", "NotValid"], schema)
    assert errors.any? { |e| e.include?("items must be unique") }
    assert errors.any? { |e| e.include?("does not match") }
  end

  def test_honors_ref_and_format
    schema = {
      "$defs" => {
        "email" => { "type" => "string", "format" => "email" }
      },
      "type" => "object",
      "required" => ["contact"],
      "properties" => {
        "contact" => { "$ref" => "#/$defs/email" }
      }
    }

    assert_empty validator.validate({ "contact" => "ops@example.com" }, schema)

    errors = validator.validate({ "contact" => "not-an-email" }, schema)
    assert errors.any? { |e| e.include?("$.contact") && e.include?("format \"email\"") }
  end

  def test_honors_pattern_properties_and_dependent_required
    schema = {
      "type" => "object",
      "additionalProperties" => false,
      "patternProperties" => {
        "^x-" => { "type" => "string" }
      },
      "dependentRequired" => {
        "credit_card" => ["billing_address"]
      }
    }

    errors = validator.validate({ "x-trace" => 123, "credit_card" => "4111" }, schema)

    assert errors.any? { |e| e.include?("$.x-trace") && e.include?("expected type string") }
    assert errors.any? { |e| e.include?("credit_card") && e.include?("billing_address") }
    refute errors.any? { |e| e.include?("unexpected property \"x-trace\"") }
  end

  def test_honors_prefix_items_and_conditionals
    tuple_schema = {
      "type" => "array",
      "prefixItems" => [
        { "type" => "string" },
        { "type" => "integer" }
      ],
      "items" => false
    }

    tuple_errors = validator.validate(["ok", "bad", "extra"], tuple_schema)
    assert tuple_errors.any? { |e| e.include?("$[1]") && e.include?("expected type integer") }
    assert tuple_errors.any? { |e| e.include?("$[2]") && e.include?("boolean schema false") }

    conditional_schema = {
      "type" => "object",
      "if" => {
        "required" => ["kind"],
        "properties" => { "kind" => { "const" => "strict" } }
      },
      "then" => { "required" => ["approved"] },
      "else" => { "required" => ["note"] }
    }

    then_errors = validator.validate({ "kind" => "strict" }, conditional_schema)
    else_errors = validator.validate({ "kind" => "loose" }, conditional_schema)
    assert then_errors.any? { |e| e.include?("missing required property \"approved\"") }
    assert else_errors.any? { |e| e.include?("missing required property \"note\"") }
  end

  def test_validate_repo_checks_cross_skill_reference_tokens
    repo_validator = RepoValidator.new
    skill = Verdify::ROOT.join("skills/release-verification/SKILL.md")
    dir = skill.dirname
    content = <<~MARKDOWN
      Read `references/environment-gitops.md`,
      `../platform-readiness/references/environment-gitops.md`, and
      `skills/platform-readiness/references/environment-gitops.md`.
    MARKDOWN

    tokens = repo_validator.send(:extract_skill_reference_tokens, content)
    assert_includes tokens, "references/environment-gitops.md"
    assert_includes tokens, "skills/platform-readiness/references/environment-gitops.md"
    assert_includes tokens, "../platform-readiness/references/environment-gitops.md"

    repo_validator.send(:validate_skill_references, skill, dir, content)
    assert repo_validator.errors.any? { |e| e.include?("referenced path does not exist: skills/platform-readiness/references/environment-gitops.md") }
    refute repo_validator.errors.any? { |e| e.include?("referenced path does not exist: references/environment-gitops.md") }
    refute repo_validator.errors.any? { |e| e.include?("referenced path does not exist: ../platform-readiness/references/environment-gitops.md") }
  end

  def test_validate_repo_rejects_unsupported_schema_keywords
    repo_validator = RepoValidator.new
    schema = {
      "type" => "object",
      "unsupportedKeyword" => true
    }

    repo_validator.send(:validate_schema_keyword_support, Verdify::ROOT.join("schemas/example.schema.yaml"), schema)

    assert repo_validator.errors.any? { |e| e.include?("unsupported JSON Schema keyword at #: unsupportedKeyword") }
  end

  def test_validate_repo_rejects_route_decision_skill_enum_drift
    path = Verdify::ROOT.join("schemas/route-decision.schema.yaml")
    schema = Verdify.safe_load_yaml(path)
    repo_validator = RepoValidator.new

    repo_validator.send(:validate_route_decision_skill_enum, path, schema)
    assert_empty repo_validator.errors

    schema.dig("properties", "next_skill", "enum").delete("issue-triage")
    repo_validator.send(:validate_route_decision_skill_enum, path, schema)
    assert repo_validator.errors.any? { |e| e.include?("properties.next_skill.enum missing canonical skills: issue-triage") }
  end

  def test_lifecycle_config_is_canonical_source_for_order_and_modes
    config = Verdify.safe_load_yaml(Verdify::ROOT.join("config/lifecycle.yaml"))
    names = config["skills"].map { |skill| skill["name"] }
    orders = config["skills"].map { |skill| skill["order"] }
    modes = config["skills"].to_h { |skill| [skill["name"], skill["modes"]] }

    assert_equal "config/lifecycle.yaml", config["canonical_source"]
    assert_equal (1..18).to_a, orders
    assert_equal Verdify::CLI::SKILLS, names
    assert_equal ["issue-triage"], config["standalone_skills"].map { |skill| skill["name"] }
    assert_includes modes["release-verification"], "review-inbox"
    assert_includes modes["release-verification"], "observability-diagnostics"
    refute_includes modes["sprint-orchestrator"], "dispatch-or-monitor"
  end

  def test_validate_repo_rejects_noncanonical_lifecycle_modes
    repo_validator = RepoValidator.new
    path = Verdify::ROOT.join("verdify.workflow.yaml")

    repo_validator.send(:validate_mode_membership, path, "sprint-orchestrator", "dispatch-or-monitor", "fixture route_hash")
    repo_validator.send(:validate_mode_membership, path, "release-verification", "gate-resolution", "fixture route_for_gate")

    assert repo_validator.errors.any? { |e| e.include?("fixture route_hash mode \"dispatch-or-monitor\" is not declared for sprint-orchestrator") }
    assert repo_validator.errors.any? { |e| e.include?("fixture route_for_gate mode \"gate-resolution\" is not declared for release-verification") }
  end

  def test_validate_repo_rejects_lifecycle_order_frontmatter_drift
    repo_validator = RepoValidator.new
    config = Verdify.safe_load_yaml(Verdify::ROOT.join("config/lifecycle.yaml"))
    skill_paths = Dir[Verdify::ROOT.join("skills/*/SKILL.md")]

    skill_paths.each do |path|
      frontmatter, = repo_validator.send(:parse_frontmatter, Pathname.new(path))
      refute frontmatter.dig("metadata", "lifecycle-order"), "#{path} must not carry legacy lifecycle-order"
    end
    refute_includes config["skills"].map { |skill| skill["name"] }, "issue-triage"
    assert_equal "standalone", config["standalone_skills"].first["category"]
  end

  def test_validate_repo_checks_cli_route_modes_against_lifecycle_config
    repo_validator = RepoValidator.new

    repo_validator.send(:validate_cli_lifecycle_alignment)

    assert_empty repo_validator.errors
  end

  def test_cli_route_hash_rejects_dynamic_noncanonical_mode
    repo = Struct.new(:github_slug, :root).new("example/repo", Verdify::ROOT)
    error = assert_raises(Verdify::UsageError) do
      Verdify::CLI.new([]).send(
        :route_hash,
        repo,
        "TEST",
        "sprint-orchestrator",
        "dispatch-or-monitor",
        "test",
        [],
        [],
        []
      )
    end

    assert_includes error.message, 'route next_mode "dispatch-or-monitor" is not declared for sprint-orchestrator'
  end

  def test_validates_all_example_artifacts
    root = Verdify::ROOT.join("examples/minimal-project/.agent-workflow")
    artifacts = Dir[root.join("**/*.{yaml,yml,json}")]
    checked = 0
    artifacts.each do |path|
      document = Verdify::SchemaValidator.load_document(path)
      next unless document.is_a?(Hash) && document["schema_ref"]
      errors = Verdify::SchemaValidator.validate_file(path, Verdify::ROOT.join("schemas", document["schema_ref"]))
      assert_empty errors, "#{path}: #{errors.join('; ')}"
      checked += 1
    end
    assert_operator checked, :>=, 15
  end

  def test_semantic_rejects_approved_project_missing_lifecycle_coverage
    path = Verdify::ROOT.join("examples/minimal-project/.agent-workflow/project/project-definition.yaml")
    document = Verdify::SchemaValidator.load_document(path)
    document["lifecycle"]["coverage"].reject! { |item| item["area"] == "infrastructure_hosting" }

    errors = Verdify::SemanticValidator.validate(document)

    assert errors.any? { |e| e.include?("missing coverage areas") && e.include?("infrastructure_hosting") }
  end

  def test_semantic_rejects_unknown_coverage_and_open_blocking_gap
    path = Verdify::ROOT.join("examples/minimal-project/.agent-workflow/project/project-definition.yaml")
    document = Verdify::SchemaValidator.load_document(path)
    document["lifecycle"]["coverage"].first["status"] = "unknown"
    document["lifecycle"]["open_gaps"] << {
      "id" => "GAP-001",
      "area" => "deployment_release_rollback",
      "question" => "Who approves rollback?",
      "impact" => "Deployment planning cannot proceed safely.",
      "owner" => "delivery-owner",
      "blocking" => true,
      "status" => "open"
    }

    errors = Verdify::SemanticValidator.validate(document)

    assert errors.any? { |e| e.include?("cannot contain unknown coverage") }
    assert errors.any? { |e| e.include?("open blocking gaps") && e.include?("GAP-001") }
  end

  def test_semantic_rejects_approved_state_of_union_with_blocking_gap
    path = Verdify::ROOT.join("examples/minimal-project/.agent-workflow/strategy/state-of-union.yaml")
    document = Verdify::SchemaValidator.load_document(path)
    document["gaps"] << {
      "id" => "GAP-001",
      "type" => "decision",
      "statement" => "Rollback approval owner is unknown.",
      "owner" => "delivery-owner",
      "blocking" => true,
      "apply_through" => "human_gate"
    }

    errors = Verdify::SemanticValidator.validate(document)

    assert errors.any? { |e| e.include?("approved state of union has blocking gaps") && e.include?("GAP-001") }
  end

  def test_semantic_requires_candidates_for_sprint_planning_handoff
    path = Verdify::ROOT.join("examples/minimal-project/.agent-workflow/strategy/state-of-union.yaml")
    document = Verdify::SchemaValidator.load_document(path)
    document["next_sprint_candidates"] = []

    errors = Verdify::SemanticValidator.validate(document)

    assert errors.any? { |e| e.include?("sprint-planning handoff requires next_sprint_candidates") }
  end

  def test_execution_runbook_marks_only_first_dependency_wave_ready
    Dir.mktmpdir("verdify-runbook-test") do |dir|
      repo = Pathname.new(dir)
      sprint_dir = repo.join(".agent-workflow/sprints/sprint-deps")
      FileUtils.mkdir_p(sprint_dir)
      File.write(sprint_dir.join("sprint-plan.yaml"), YAML.dump(two_wave_sprint_plan))

      output = sprint_dir.join("execution/sprint-execution-runbook.yaml")
      stdout, stderr, status = Open3.capture3(
        "ruby",
        Verdify::ROOT.join("skills/sprint-orchestrator/scripts/build_execution_runbook.rb").to_s,
        "--repo",
        repo.to_s,
        "--sprint",
        "sprint-deps",
        "--output",
        output.to_s
      )

      assert status.success?, stderr
      assert_equal "#{output}\n", stdout
      runbook = YAML.safe_load(output.read, permitted_classes: [], aliases: false)
      states = runbook["lanes"].to_h { |lane| [lane["lane_id"], lane["dependency_state"]] }
      tools = runbook.dig("platform", "required_tools").map { |tool| tool["name"] }

      assert_equal "ready", states["lane-a"]
      assert_equal "waiting", states["lane-b"]
      assert_equal ["add_worktree_agent"], tools
    end
  end

  def test_platform_control_request_uses_add_worktree_agent_and_derives_human_gate
    Dir.mktmpdir("verdify-control-request-test") do |dir|
      repo = Pathname.new(dir)
      runbook_path = repo.join(".agent-workflow/sprints/sprint-deps/execution/sprint-execution-runbook.yaml")
      FileUtils.mkdir_p(runbook_path.dirname)
      File.write(runbook_path, YAML.dump(minimal_runbook))

      stdout, stderr, status = Open3.capture3(
        "ruby",
        Verdify::ROOT.join("skills/sprint-orchestrator/scripts/build_platform_control_requests.rb").to_s,
        "--repo",
        repo.to_s,
        "--runbook",
        runbook_path.to_s,
        "--mutation-level",
        "protected_write",
        "--github-identity",
        "jvallery"
      )

      assert status.success?, stderr
      output_path = Pathname.new(stdout.lines.first.strip)
      request = YAML.safe_load(output_path.read, permitted_classes: [], aliases: false)
      schema = Verdify::SchemaValidator.load_document(Verdify::ROOT.join("schemas/agent-platform-control-request.schema.yaml"))

      assert_empty validator.validate(request, schema)
      assert_equal "add_worktree_agent", request.dig("operation", "operation_id")
      assert_equal "add_worktree_agent", request.dig("operation", "tool_name")
      assert_equal "POST", request.dig("operation", "method")
      assert_equal "protected_write", request.dig("operation", "mutation_level")
      assert_equal true, request.dig("review", "human_gate_required")
      assert_equal "#/inputs/redacted_payload", request.dig("inputs", "redacted_payload_ref")
      assert_equal "lane/a", request.dig("inputs", "redacted_payload", "branch")
      assert_equal "codex", request.dig("inputs", "redacted_payload", "runtime")
      assert_equal "jvallery", request.dig("inputs", "redacted_payload", "github_identity")
      assert_equal "lane-a", request.dig("inputs", "redacted_payload", "user")
      assert_equal request.dig("operation", "idempotency_key"), request.dig("inputs", "redacted_payload", "idempotency_key")
      assert_equal "/api/repos/example/repo/agents", request.dig("inputs", "redacted_payload", "api_request", "path")
      assert_equal "lane/a", request.dig("inputs", "redacted_payload", "api_request", "body", "base_ref")
      refute_includes output_path.read, "agent_platform.session"
      refute_includes output_path.read, "agent_platform.terminal"
    end
  end

  def test_semantic_rejects_add_worktree_agent_without_structured_payload
    document = minimal_control_request
    document["operation"]["operation_id"] = "add_worktree_agent"
    document["operation"]["tool_name"] = "add_worktree_agent"
    document["operation"]["idempotency_key"] = "exec-sprint:lane-a:add-worktree-agent"
    document["inputs"]["redacted_payload_ref"] = nil

    errors = Verdify::SemanticValidator.validate(document)

    assert errors.any? { |e| e.include?("$.inputs.redacted_payload_ref") }
    assert errors.any? { |e| e.include?("$.inputs.redacted_payload") }
  end

  def test_semantic_rejects_protected_control_request_without_human_approval
    document = minimal_control_request
    document["status"] = "authorized"
    document["operation"]["mutation_level"] = "protected_write"
    document["authorization"]["approved_by"] = nil
    document["authorization"]["approved_at"] = nil
    document["review"]["decision"] = "pending"
    document["review"]["decided_at"] = nil

    errors = Verdify::SemanticValidator.validate(document)

    assert errors.any? { |e| e.include?("$.review.human_gate_required") }
    assert errors.any? { |e| e.include?("$.review.decision") }
    assert errors.any? { |e| e.include?("$.authorization.approved_by") }
  end

  def test_semantic_rejects_verified_release_without_approval_or_independent_verifier
    path = Verdify::ROOT.join("examples/minimal-project/.agent-workflow/sprints/2026-06-22-a/release/release-verification.yaml")
    document = Verdify::SchemaValidator.load_document(path)
    document["deployment"]["approval"] = {
      "required" => false,
      "approved_by" => nil,
      "approved_at" => nil,
      "evidence" => nil
    }
    document["deployment"]["deployer"] = document["verifier"]

    errors = Verdify::SemanticValidator.validate(document)

    assert errors.any? { |e| e.include?("$.deployment.approval.required") }
    assert errors.any? { |e| e.include?("$.deployment.approval.approved_by") }
    assert errors.any? { |e| e.include?("$.verifier: verified release verifier must differ from deployer") }
  end

  private

  def two_wave_sprint_plan
    {
      "schema_ref" => "sprint-plan.schema.yaml",
      "kind" => "SprintPlan",
      "schema_version" => "1.0",
      "sprint_id" => "sprint-deps",
      "status" => "approved",
      "goal" => "Exercise dependency wave ordering.",
      "baseline_sha" => "1111111111111111111111111111111111111111",
      "github" => { "repository" => "example/repo", "milestone" => nil, "project" => nil },
      "issue_ids" => [1, 2],
      "scope" => ["Dispatch lanes in dependency order."],
      "non_goals" => [],
      "acceptance_criteria" => [
        { "id" => "SPR-AC-01", "statement" => "Only first wave is ready.", "lane_ids" => ["lane-a", "lane-b"], "evidence_expected" => ["runbook"] }
      ],
      "risks" => [],
      "lanes" => [
        { "lane_id" => "lane-a", "issue_ids" => [1], "contract_path" => ".agent-workflow/sprints/sprint-deps/lanes/contracts/lane-a.contract.yaml", "branch" => "lane/a", "owner" => "worker-a", "reviewer" => "critic", "summary" => "First wave lane." },
        { "lane_id" => "lane-b", "issue_ids" => [2], "contract_path" => ".agent-workflow/sprints/sprint-deps/lanes/contracts/lane-b.contract.yaml", "branch" => "lane/b", "owner" => "worker-b", "reviewer" => "critic", "summary" => "Second wave lane." }
      ],
      "dependency_order" => [["lane-a"], ["lane-b"]],
      "deployment_expectations" => [],
      "review_plan" => {
        "qa_milestones" => [],
        "human_review_milestones" => [
          { "id" => "HR-01", "name" => "Review", "owner" => "owner", "trigger" => "runbook ready", "review_packet_path" => ".agent-workflow/sprints/sprint-deps/review/review-inbox-packet.yaml" }
        ],
        "user_stories_for_review" => [
          { "id" => "US-01", "statement" => "Review ordered dispatch.", "issue_ids" => [1, 2], "lane_ids" => ["lane-a", "lane-b"], "acceptance_refs" => ["SPR-AC-01"] }
        ],
        "reporting_summary" => { "included" => [], "deferred" => [], "ownership" => [], "next_review" => "After runbook generation." }
      },
      "approval" => { "status" => "approved", "approver" => "owner", "approved_at" => "2026-06-24T00:00:00Z" }
    }
  end

  def minimal_runbook
    {
      "schema_ref" => "sprint-execution-runbook.schema.yaml",
      "kind" => "SprintExecutionRunbook",
      "schema_version" => "1.0",
      "runbook_id" => "exec-sprint-deps",
      "status" => "ready",
      "sprint_id" => "sprint-deps",
      "wave_id" => nil,
      "repository" => "example/repo",
      "prepared_at" => "2026-06-24T00:00:00Z",
      "controller" => {
        "session_id" => "controller-sprint-deps",
        "owner" => "sprint-orchestrator",
        "authority" => "Dispatch lanes.",
        "interfaces" => ["agent_platform_mcp", "github"],
        "poll_interval_minutes" => 5,
        "delegation_policy" => "Approved lanes only."
      },
      "prerequisites" => {
        "approved_sprint_plan" => ".agent-workflow/sprints/sprint-deps/sprint-plan.yaml",
        "approved_lane_contracts" => [],
        "wave_release_plan" => nil,
        "platform_readiness" => nil,
        "open_blockers" => []
      },
      "platform" => {
        "mcp_server" => "in-pod-controller-mcp",
        "api_ref" => "POST /api/repos/example/repo/agents",
        "auth_mode" => "mcp_session",
        "required_tools" => [{ "name" => "add_worktree_agent", "purpose" => "Dispatch lane.", "required" => true }],
        "terminal_access" => { "mode" => "none", "operator_visible" => false, "attach_refs" => [] },
        "fallback_policy" => "Stop if unavailable."
      },
      "cadence" => { "poll_interval_minutes" => 5, "heartbeat_timeout_minutes" => 15, "loop_until" => ["Done."] },
      "lanes" => [
        {
          "lane_id" => "lane-a",
          "issue_ids" => [1],
          "contract_path" => ".agent-workflow/sprints/sprint-deps/lanes/contracts/lane-a.contract.yaml",
          "branch" => "lane/a",
          "owner" => "worker-a",
          "dependency_state" => "ready",
          "platform_session" => {
            "create_operation_ref" => ".agent-workflow/sprints/sprint-deps/execution/control-requests/lane-a-add-worktree-agent.yaml",
            "session_id" => nil,
            "executor" => "codex",
            "model" => nil,
            "effort" => nil,
            "status" => "planned"
          },
          "prompt" => { "prompt_path" => ".agent-workflow/sprints/sprint-deps/prompts/lane-a.worker.md", "manifest_path" => nil, "contract_hash" => nil },
          "terminal" => { "tmux_session" => nil, "browser_terminal_url" => nil, "operator_attach_required" => false },
          "status" => "planned"
        }
      ],
      "coordination" => { "poll_steps" => ["Poll."], "controller_responses" => ["Respond."], "coordination_request_policy" => "Approved only.", "escalation_paths" => [] },
      "ci_cd" => { "required_checks" => [], "workflows" => [], "merge_policy" => "After review.", "deployment_trigger" => "After approval.", "evidence_refs" => [] },
      "deployment" => { "target_environment" => nil, "namespace" => nil, "strategy" => "None.", "approval_required" => false, "rollout_refs" => [], "rollback_refs" => [] },
      "review" => { "review_packet_path" => ".agent-workflow/sprints/sprint-deps/review/review-inbox-packet.yaml", "human_review_trigger" => "Ready.", "reviewer_visibility" => [] },
      "ledger" => { "controller_state_path" => ".agent-workflow/controller/controller-state.yaml", "session_ledger_path" => ".agent-workflow/controller/session-ledger.yaml", "required_events" => ["lane_dispatched"] },
      "stop_conditions" => ["Stop."],
      "handoff" => { "next_skill" => "sprint-orchestrator", "next_mode" => "platform-dispatch", "reason" => "Dispatch." }
    }
  end

  def minimal_control_request
    Verdify::SchemaValidator.load_document(Verdify::ROOT.join("examples/minimal-project/.agent-workflow/platform/agent-platform-control-request.yaml"))
  end
end
