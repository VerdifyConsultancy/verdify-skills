# frozen_string_literal: true

# Issue #73: approving critic evidence must be exact and non-vacuous, and
# closeout claims must be a truthful contract-valid subset. These tests drive
# the semantic validator, the lane review validator, and the end-to-end
# consumers (route/review-inbox authorization, delivery-gate critic
# evaluation, terminal-receipt validation) with negative and positive
# fixtures.
require "digest"
require "fileutils"
require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"
require "yaml"
require_relative "../lib/verdify"

class CriticEvidenceTest < Minitest::Test
  SPRINT = "2026-06-22-a"
  LANE = "issue-123-api"
  CONTRACT_REL = ".agent-workflow/sprints/#{SPRINT}/lanes/contracts/#{LANE}.contract.yaml"
  CLOSEOUT_REL = ".agent-workflow/sprints/#{SPRINT}/lanes/closeout/#{LANE}.closeout.yaml"
  CRITIC_REL = ".agent-workflow/sprints/#{SPRINT}/critic/#{LANE}.critic.yaml"

  # --- LANE-AC-01: empty approving assessment is a bounded typed failure ---

  def test_semantic_rejects_empty_acceptance_assessment_for_each_approving_outcome
    %w[approve approve_with_risks].each do |outcome|
      critic = example_critic_document
      critic["outcome"] = outcome
      critic["acceptance_assessment"] = []
      critic["residual_risks"] = ["recorded risk"] if outcome == "approve_with_risks"

      errors = Verdify::SemanticValidator.validate(critic)

      assert errors.any? { |error| error.include?("$.acceptance_assessment: #{outcome} requires an acceptance assessment") },
             "expected bounded empty-assessment error for #{outcome}, got: #{errors.inspect}"
    end
  end

  def test_review_chain_rejects_empty_approving_assessment
    chain = build_lane(critic_assessment: [])
    result = validator(chain).validate_critic(tip_sha: chain[:report_head])

    refute result.valid?
    assert result.errors.any? { |error| error.include?("requires an acceptance assessment") }
    assert result.errors.any? { |error| error.include?("approving critic report does not assess lane contract criteria: LANE-AC-01, LANE-AC-02") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  # --- LANE-AC-02: exact order-independent criterion reconciliation ---

  def test_exact_assessment_is_valid_in_any_order
    chain = build_lane(critic_assessment: [assessment("LANE-AC-02"), assessment("LANE-AC-01")])
    result = validator(chain).validate_critic(tip_sha: chain[:report_head])

    assert result.valid?, result.errors.join("\n")
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_duplicate_criterion_ids_fail_naming_offending_ids
    chain = build_lane(critic_assessment: [assessment("LANE-AC-01"), assessment("LANE-AC-01"), assessment("LANE-AC-02")])
    result = validator(chain).validate_critic(tip_sha: chain[:report_head])

    refute result.valid?
    assert result.errors.any? { |error| error.include?("$.acceptance_assessment: criterion IDs must be unique: LANE-AC-01") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_unknown_criterion_id_fails_naming_offending_id
    chain = build_lane(critic_assessment: [assessment("LANE-AC-01"), assessment("LANE-AC-02"), assessment("LANE-AC-99")])
    result = validator(chain).validate_critic(tip_sha: chain[:report_head])

    refute result.valid?
    assert result.errors.any? { |error| error.include?("critic report assesses criteria missing from the lane contract: LANE-AC-99") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_missing_contract_criterion_fails_naming_offending_id
    chain = build_lane(critic_assessment: [assessment("LANE-AC-01")])
    result = validator(chain).validate_critic(tip_sha: chain[:report_head])

    refute result.valid?
    assert result.errors.any? { |error| error.include?("approving critic report does not assess lane contract criteria: LANE-AC-02") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  # --- LANE-AC-03: approving assessments must be satisfied with evidence ---

  def test_unsatisfied_assessment_in_approving_report_fails
    chain = build_lane(critic_assessment: [assessment("LANE-AC-01"), assessment("LANE-AC-02", state: "uncertain")])
    result = validator(chain).validate_critic(tip_sha: chain[:report_head])

    refute result.valid?
    assert result.errors.any? { |error| error.include?("approval requires satisfied criteria (LANE-AC-02)") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_blank_evidence_in_approving_report_fails
    chain = build_lane(critic_assessment: [assessment("LANE-AC-01"), assessment("LANE-AC-02", evidence: ["  "])])
    result = validator(chain).validate_critic(tip_sha: chain[:report_head])

    refute result.valid?
    assert result.errors.any? { |error| error.include?("approval requires non-empty evidence (LANE-AC-02)") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_schema_still_rejects_empty_evidence_array
    critic = example_critic_document
    critic["acceptance_assessment"] = [{ "criterion_id" => "LANE-AC-01", "assessment" => "satisfied", "evidence" => [] }]
    schema = Verdify::SchemaValidator.load_document(Verdify::ROOT.join("schemas/critic-report.schema.yaml"))

    errors = Verdify::SchemaValidator.new.validate(critic, schema)

    assert errors.any? { |error| error.include?("evidence") && error.include?("at least 1") },
           "expected schema minItems rejection, got: #{errors.inspect}"
  end

  # --- LANE-AC-04: non-approving reports stay valid when partial or empty ---

  def test_request_fixes_report_remains_valid_when_empty
    critic = example_critic_document
    critic["outcome"] = "request_fixes"
    critic["acceptance_assessment"] = []
    assert_empty Verdify::SemanticValidator.validate(critic)

    chain = build_lane(critic_outcome: "request_fixes", critic_assessment: [])
    result = validator(chain).validate_critic(tip_sha: chain[:report_head])
    assert result.valid?, result.errors.join("\n")
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_request_fixes_report_remains_valid_when_partial
    chain = build_lane(critic_outcome: "request_fixes", critic_assessment: [assessment("LANE-AC-01", state: "not_satisfied")])
    result = validator(chain).validate_critic(tip_sha: chain[:report_head])

    assert result.valid?, result.errors.join("\n")
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_request_fixes_report_rejects_duplicate_and_unknown_ids
    duplicated = build_lane(critic_outcome: "request_fixes",
                            critic_assessment: [assessment("LANE-AC-01", state: "not_satisfied"), assessment("LANE-AC-01", state: "not_satisfied")])
    result = validator(duplicated).validate_critic(tip_sha: duplicated[:report_head])
    refute result.valid?
    assert result.errors.any? { |error| error.include?("$.acceptance_assessment: criterion IDs must be unique: LANE-AC-01") }

    unknown = build_lane(critic_outcome: "request_fixes", critic_assessment: [assessment("LANE-AC-77", state: "not_satisfied")])
    unknown_result = validator(unknown).validate_critic(tip_sha: unknown[:report_head])
    refute unknown_result.valid?
    assert unknown_result.errors.any? { |error| error.include?("critic report assesses criteria missing from the lane contract: LANE-AC-77") }
  ensure
    FileUtils.rm_rf(duplicated[:root]) if duplicated
    FileUtils.rm_rf(unknown[:root]) if unknown
  end

  # --- LANE-AC-05: closeout claims are a truthful contract-valid subset ---

  def test_closeout_truthful_subset_with_omission_is_valid
    chain = build_lane(closeout_claims: [claim("LANE-AC-01")])
    result = validator(chain).validate_closeout(evidence_head_sha: chain[:evidence_head])

    assert result.valid?, result.errors.join("\n")
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_closeout_fabricated_criterion_fails_naming_offending_id
    chain = build_lane(closeout_claims: [claim("LANE-AC-01"), claim("LANE-AC-99")])
    result = validator(chain).validate_closeout(evidence_head_sha: chain[:evidence_head])

    refute result.valid?
    assert result.errors.any? { |error| error.include?("closeout claims criteria missing from the lane contract: LANE-AC-99") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_closeout_duplicate_claims_fail_naming_offending_id
    chain = build_lane(closeout_claims: [claim("LANE-AC-01"), claim("LANE-AC-01")])
    result = validator(chain).validate_closeout(evidence_head_sha: chain[:evidence_head])

    refute result.valid?
    assert result.errors.any? { |error| error.include?("$.acceptance_evidence: criterion IDs must be unique: LANE-AC-01") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_closeout_future_phase_evidence_claim_fails_with_bounded_error
    chain = build_lane(closeout_claims: [
                         claim("LANE-AC-01"),
                         claim("LANE-AC-02", evidence_ids: ["fresh-critic-approval", "github-checks-at-head", "terminal-receipt"])
                       ])
    result = validator(chain).validate_closeout(evidence_head_sha: chain[:evidence_head])

    refute result.valid?
    error = result.errors.find { |item| item.include?("closeout claims future-phase evidence for LANE-AC-02") }
    refute_nil error, result.errors.join("\n")
    assert_includes error, "fresh-critic-approval"
    assert_includes error, "github-checks-at-head"
    assert_includes error, "terminal-receipt"
    assert_includes error, "cannot claim critic, CI, integration, deployment, or outcome evidence"
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_closeout_recorded_worker_suites_are_not_future_phase_claims
    # A worker-run suite may legitimately be named after the surface it tests
    # (for example "critic-evidence-suite"); recording it in
    # validation_results keeps the claim truthful.
    chain = build_lane(closeout_validation_ids: ["test", "critic-evidence-suite", "delivery-gate-regression"],
                       closeout_claims: [
                         claim("LANE-AC-01", evidence_ids: ["critic-evidence-suite"]),
                         claim("LANE-AC-02", evidence_ids: ["delivery-gate-regression", "diff-review-notes"])
                       ])
    result = validator(chain).validate_closeout(evidence_head_sha: chain[:evidence_head])

    assert result.valid?, result.errors.join("\n")
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  # --- LANE-AC-07: vacuous approving evidence cannot authorize downstream paths ---

  def test_vacuous_approving_report_fails_delivery_gate_critic_evaluation
    chain = build_lane(critic_assessment: [])
    flow = YAML.safe_load(Verdify::ROOT.join("config/github-primitives.yaml").read, permitted_classes: [], aliases: false).fetch("release_branch_flow")
    event = {
      "repository" => { "full_name" => flow.fetch("repository") },
      "number" => 456,
      "pull_request" => {
        "number" => 456,
        "base" => { "ref" => flow.fetch("development_branch"), "sha" => chain[:baseline], "repo" => { "full_name" => flow.fetch("repository") } },
        "head" => { "ref" => "lane/#{LANE}", "sha" => chain[:report_head], "repo" => { "full_name" => flow.fetch("repository") } },
        "user" => { "login" => "worker" },
        "body" => "- Lane: `#{LANE}`\n- Contract: `#{CONTRACT_REL}`\n"
      }
    }
    event_path = File.join(chain[:root], "event.json")
    File.write(event_path, JSON.generate(event))

    stdout, stderr, status = Open3.capture3(
      "ruby", Verdify::ROOT.join("scripts/delivery-gate.rb").to_s,
      "--event", event_path, "--repo", chain[:root]
    )

    assert_equal 1, status.exitstatus, "expected the delivery gate to fail, got status #{status.exitstatus}: #{stdout}#{stderr}"
    assert_includes stderr, "approving critic report does not assess lane contract criteria: LANE-AC-01, LANE-AC-02"
    assert_includes stderr, "requires an acceptance assessment"
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_fabricated_approving_report_fails_delivery_gate_critic_evaluation
    chain = build_lane(critic_assessment: [assessment("LANE-AC-01"), assessment("LANE-AC-02"), assessment("LANE-AC-99")])
    flow = YAML.safe_load(Verdify::ROOT.join("config/github-primitives.yaml").read, permitted_classes: [], aliases: false).fetch("release_branch_flow")
    event = {
      "repository" => { "full_name" => flow.fetch("repository") },
      "number" => 456,
      "pull_request" => {
        "number" => 456,
        "base" => { "ref" => flow.fetch("development_branch"), "sha" => chain[:baseline], "repo" => { "full_name" => flow.fetch("repository") } },
        "head" => { "ref" => "lane/#{LANE}", "sha" => chain[:report_head], "repo" => { "full_name" => flow.fetch("repository") } },
        "user" => { "login" => "worker" },
        "body" => "- Lane: `#{LANE}`\n- Contract: `#{CONTRACT_REL}`\n"
      }
    }
    event_path = File.join(chain[:root], "event.json")
    File.write(event_path, JSON.generate(event))

    _stdout, stderr, status = Open3.capture3(
      "ruby", Verdify::ROOT.join("scripts/delivery-gate.rb").to_s,
      "--event", event_path, "--repo", chain[:root]
    )

    assert_equal 1, status.exitstatus
    assert_includes stderr, "critic report assesses criteria missing from the lane contract: LANE-AC-99"
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_vacuous_approving_report_fails_terminal_receipt_lane_validation
    chain = build_lane(critic_assessment: [])
    receipt_rel = ".agent-workflow/sprints/#{SPRINT}/terminal/terminal-receipt.yaml"
    receipt_path = File.join(chain[:root], receipt_rel)
    FileUtils.mkdir_p(File.dirname(receipt_path))
    File.write(receipt_path, YAML.dump(minimal_receipt(chain)))

    result = Verdify::SprintTerminalReceipt.new(repo: chain[:root]).validate_local(
      receipt_path: receipt_path,
      require_commit_shape: false
    )

    refute result.valid?
    assert result.errors.any? { |error| error.include?("#{LANE}:") && error.include?("approving critic report does not assess lane contract criteria: LANE-AC-01, LANE-AC-02") },
           result.errors.join("\n")
    assert result.errors.any? { |error| error.include?("requires an acceptance assessment") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  private

  def example_critic_document
    Verdify::SchemaValidator.load_document(
      Verdify::ROOT.join("examples/minimal-project/.agent-workflow/sprints/#{SPRINT}/critic/#{LANE}.critic.yaml")
    )
  end

  def assessment(criterion_id, state: "satisfied", evidence: ["test"])
    { "criterion_id" => criterion_id, "assessment" => state, "evidence" => evidence }
  end

  def claim(criterion_id, evidence_ids: ["test"], state: "satisfied")
    { "criterion_id" => criterion_id, "evidence_ids" => evidence_ids, "assessment" => state }
  end

  def default_assessments
    [assessment("LANE-AC-01"), assessment("LANE-AC-02")]
  end

  def default_claims
    [claim("LANE-AC-01"), claim("LANE-AC-02")]
  end

  # Builds a dispatch -> implementation -> closeout evidence -> critic report
  # chain against a two-criterion lane contract so exactness (duplicates,
  # unknown IDs, omissions) is observable.
  def build_lane(critic_outcome: "approve", critic_assessment: :exact, closeout_claims: :exact, closeout_validation_ids: ["test"])
    critic_assessment = default_assessments if critic_assessment == :exact
    closeout_claims = default_claims if closeout_claims == :exact
    root = Dir.mktmpdir("verdify-critic-evidence-")
    git(root, "init", "-q", "-b", "main")
    git(root, "config", "user.name", "Verdify Test")
    git(root, "config", "user.email", "verdify-test@example.invalid")
    File.write(File.join(root, "README.md"), "# Test\n")
    git(root, "add", ".")
    git(root, "commit", "-qm", "baseline")
    baseline = git(root, "rev-parse", "HEAD").strip

    contract_path = File.join(root, CONTRACT_REL)
    closeout_path = File.join(root, CLOSEOUT_REL)
    critic_path = File.join(root, CRITIC_REL)
    [contract_path, closeout_path, critic_path].each { |path| FileUtils.mkdir_p(File.dirname(path)) }

    contract = Verdify::SchemaValidator.load_document(
      Verdify::ROOT.join("examples/minimal-project/.agent-workflow/sprints/#{SPRINT}/lanes/contracts/#{LANE}.contract.yaml")
    )
    contract["baseline_sha"] = baseline
    contract["branch"] = "main"
    contract["approval"] = { "status" => "approved", "approver" => "owner", "approved_at" => "2026-07-12T00:00:00Z" }
    contract["acceptance_criteria"] = [
      { "id" => "LANE-AC-01", "statement" => "Health endpoint returns ok.",
        "sprint_acceptance_ids" => ["SPR-AC-01"], "evidence_required" => ["passing API contract test"] },
      { "id" => "LANE-AC-02", "statement" => "Health endpoint returns the current revision.",
        "sprint_acceptance_ids" => ["SPR-AC-01"], "evidence_required" => ["passing revision test"] }
    ]
    File.write(contract_path, YAML.dump(contract))
    git(root, "add", CONTRACT_REL)
    git(root, "commit", "-qm", "approve lane contract")

    File.write(File.join(root, "implementation.txt"), "implemented\n")
    git(root, "add", "implementation.txt")
    git(root, "commit", "-qm", "implementation")
    implementation = git(root, "rev-parse", "HEAD").strip

    closeout = {
      "schema_ref" => "lane-closeout.schema.yaml", "kind" => "LaneCloseout", "schema_version" => "2.0",
      "sprint_id" => SPRINT, "lane_id" => LANE, "status" => "ready_for_critic",
      "issue_ids" => [123], "pull_request" => 456, "baseline_sha" => baseline,
      "implementation_head_sha" => implementation, "validated_head_sha" => implementation,
      "contract_hash" => Digest::SHA256.file(contract_path).hexdigest,
      "changed_paths" => ["implementation.txt"],
      "validation_results" => closeout_validation_ids.map do |id|
        { "id" => id, "command" => "true", "exit_status" => 0, "result" => "passed", "executed_at" => "2026-07-12T00:01:00Z", "artifact" => nil }
      end,
      "acceptance_evidence" => closeout_claims,
      "discovered_issues" => [], "residual_risks" => [], "worktree_clean" => true,
      "worker_agent" => "worker-agent", "worker_session_id" => "worker-session",
      "completed_at" => "2026-07-12T00:02:00Z", "limitations" => []
    }
    File.write(closeout_path, YAML.dump(closeout))
    git(root, "add", CLOSEOUT_REL)
    git(root, "commit", "-qm", "worker evidence")
    evidence = git(root, "rev-parse", "HEAD").strip

    critic = {
      "schema_ref" => "critic-report.schema.yaml", "kind" => "CriticReport", "schema_version" => "2.0",
      "sprint_id" => SPRINT, "lane_id" => LANE, "pull_request" => 456,
      "worker_agent" => "worker-agent", "worker_session_id" => "worker-session",
      "critic_agent" => "critic-agent", "critic_session_id" => "critic-session",
      "implementation_head_sha" => implementation, "evidence_head_sha" => evidence, "reviewed_head_sha" => evidence,
      "closeout_path" => CLOSEOUT_REL, "closeout_sha256" => Digest::SHA256.file(closeout_path).hexdigest,
      "review_worktree" => root, "outcome" => critic_outcome, "findings" => [],
      "acceptance_assessment" => critic_assessment,
      "evidence_assessment" => ["Chain reviewed."], "integration_risks" => [], "residual_risks" => [],
      "reviewed_at" => "2026-07-12T00:03:00Z"
    }
    File.write(critic_path, YAML.dump(critic))
    git(root, "add", CRITIC_REL)
    git(root, "commit", "-qm", "critic report")
    report = git(root, "rev-parse", "HEAD").strip

    {
      root: root, baseline: baseline,
      contract_path: contract_path, closeout_path: closeout_path, critic_path: critic_path,
      implementation_head: implementation, evidence_head: evidence, report_head: report
    }
  end

  def minimal_receipt(chain)
    {
      "schema_ref" => "sprint-terminal-receipt.schema.yaml", "kind" => "SprintTerminalReceipt", "schema_version" => "1.0",
      "sprint_id" => SPRINT, "mode" => "normal", "recovery_bundle" => nil,
      "receipt_base_sha" => chain[:report_head], "integration_branch" => "dev",
      "controller" => {
        "ref" => "controller/#{SPRINT}", "head_sha" => chain[:report_head],
        "packet_commit_sha" => chain[:report_head], "release_commit_sha" => chain[:report_head],
        "outcome_commit_sha" => chain[:report_head],
        "packet_path" => ".agent-workflow/sprints/#{SPRINT}/review/review-inbox-packet.yaml",
        "packet_sha256" => "0" * 64, "release_sha256" => "0" * 64, "outcome_sha256" => "0" * 64
      },
      "lanes" => [{
        "lane_id" => LANE, "issue_ids" => [123], "branch" => "main", "pull_request" => 456,
        "dispatch_head_sha" => chain[:baseline], "implementation_head_sha" => chain[:implementation_head],
        "evidence_head_sha" => chain[:evidence_head], "critic_report_head_sha" => chain[:report_head],
        "merge_commit_sha" => chain[:report_head]
      }],
      "artifacts" => {
        "plan_sha256" => "0" * 64, "status_sha256" => "0" * 64,
        "release_sha256" => "0" * 64, "outcome_sha256" => "0" * 64
      },
      "terminal" => {
        "integrated_sha" => chain[:report_head], "plan_status" => "complete", "status_state" => "COMPLETE",
        "release_status" => "verified", "outcome_decision" => "accepted"
      },
      "generated_at" => "2026-07-12T00:04:00Z", "generator" => "critic-evidence-test"
    }
  end

  def validator(chain)
    Verdify::LaneReviewValidator.new(
      repo: chain[:root],
      contract_path: chain[:contract_path],
      closeout_path: chain[:closeout_path],
      critic_path: chain[:critic_path]
    )
  end

  def git(root, *args)
    stdout, stderr, status = Open3.capture3("git", "-C", root, *args)
    raise "git #{args.join(' ')} failed: #{stderr}" unless status.success?

    stdout
  end
end
