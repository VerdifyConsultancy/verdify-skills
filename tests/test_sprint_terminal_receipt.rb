# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "minitest/autorun"
require "tmpdir"
require "yaml"
require_relative "../lib/verdify"

class SprintTerminalReceiptTest < Minitest::Test
  SPRINT = "2026-06-22-a"
  LANE = "issue-123-api"
  PR = 456

  def teardown
    FileUtils.rm_rf(@root) if @root
  end

  def test_normal_receipt_closes_integrated_sprint_and_survives_later_dev_commits
    fixture = build_fixture
    validator = receipt_validator(fixture)
    assert_equal [SPRINT], validator.integrated_unterminated_sprints(ref: fixture[:base])

    receipt = generate_and_commit_receipt(fixture, validator)
    assert_equal "normal", receipt["mode"]
    validation = validator.validate_full(
      receipt_path: receipt_path,
      expected_base_sha: fixture[:base],
      expected_mode: "normal"
    )
    assert validation.valid?, validation.errors.join("\n")

    git("checkout", "-q", "dev")
    git("merge", "--no-ff", "-qm", "merge terminal receipt", "receipt/#{SPRINT}")
    dev_head = sha
    assert validator.terminal_at?(SPRINT, ref: dev_head)
    assert_empty validator.integrated_unterminated_sprints(ref: dev_head)

    File.write(File.join(@root, "later.txt"), "later dev work\n")
    git("add", "later.txt")
    git("commit", "-qm", "later dev work")
    assert validator.terminal_at?(SPRINT, ref: sha)
    stdout, = capture_io do
      assert_equal 0, Verdify::CLI.run(["route", "--repo", @root, "--json"])
    end
    route = JSON.parse(stdout)
    refute_equal "SPRINT_TRANSACTION_AMBIGUOUS", route["current_state"]
    assert_equal "STATE_OF_UNION_MISSING", route["current_state"]
  end

  def test_receipt_rejects_tampered_terminal_artifact
    fixture = build_fixture
    validator = receipt_validator(fixture)
    generate_and_commit_receipt(fixture, validator)
    plan = YAML.safe_load(File.read(plan_path), permitted_classes: [], aliases: false)
    plan["goal"] = "tampered after receipt generation"
    File.write(plan_path, YAML.dump(plan))
    git("add", plan_path)
    git("commit", "-qm", "tamper with terminal plan")

    result = validator.validate_local(receipt_path: receipt_path, expected_base_sha: fixture[:base])
    refute result.valid?
    assert result.errors.any? { |error| error.include?("plan artifact digest") }
    assert result.errors.any? { |error| error.include?("share one receipt commit") }
  end

  def test_full_validation_rejects_newer_in_progress_trusted_check
    fixture = build_fixture
    checks = trusted_checks(fixture[:report])
    checks << checks.find { |check| check["name"] == "validate" }.merge(
      "id" => 99,
      "status" => "in_progress",
      "conclusion" => nil,
      "created_at" => "2026-07-10T01:00:00Z",
      "started_at" => "2026-07-10T01:00:01Z",
      "completed_at" => nil
    )
    validator = receipt_validator(fixture, checks: checks)
    generate_and_commit_receipt(fixture, validator)

    result = validator.validate_full(
      receipt_path: receipt_path,
      expected_base_sha: fixture[:base],
      expected_mode: "normal"
    )
    refute result.valid?
    assert result.errors.any? { |error| error.include?("latest trusted validate check") }
  end

  def test_controller_cannot_mutate_p_r_o_after_receipt_generation
    fixture = build_fixture
    validator = receipt_validator(fixture)
    generate_and_commit_receipt(fixture, validator)
    git("checkout", "-q", "controller/#{SPRINT}")
    packet = YAML.safe_load(File.read(File.join(@root, relative_packet_path)), permitted_classes: [], aliases: false)
    packet["recommendation"]["outcome"] = "request_changes"
    File.write(File.join(@root, relative_packet_path), YAML.dump(packet))
    git("add", relative_packet_path)
    git("commit", "-qm", "mutate controller packet")
    git("checkout", "-q", "receipt/#{SPRINT}")

    result = validator.validate_full(
      receipt_path: receipt_path,
      expected_base_sha: fixture[:base],
      expected_mode: "normal"
    )
    refute result.valid?
    assert result.errors.any? { |error| error.include?("controller head changed") }
  end

  def test_full_validation_rejects_descendant_commits_after_receipt_commit
    fixture = build_fixture
    validator = receipt_validator(fixture)
    generate_and_commit_receipt(fixture, validator)
    transient = File.join(@root, "transient.txt")
    File.write(transient, "not part of the final diff\n")
    git("add", "transient.txt")
    git("commit", "-qm", "post-receipt transient change")
    FileUtils.rm_f(transient)
    git("add", "transient.txt")
    git("commit", "-qm", "remove post-receipt transient change")

    result = validator.validate_full(
      receipt_path: receipt_path,
      expected_base_sha: fixture[:base],
      expected_mode: "normal"
    )
    refute result.valid?
    assert result.errors.any? { |error| error.include?("pull request head must equal") }
  end

  def test_generator_rejects_release_that_does_not_contain_lane_merge
    fixture = build_fixture(release_integrated: :baseline)
    validator = receipt_validator(fixture)
    error = assert_raises(Verdify::CommandError) do
      validator.write!(
        sprint_id: SPRINT,
        controller_ref: "controller/#{SPRINT}",
        receipt_base_sha: fixture[:base]
      )
    end
    assert_includes error.message, "verified integrated SHA does not contain lane"
  end

  def test_generator_rejects_wrong_packet_base_ref
    fixture = build_fixture(packet_base_ref: "main")
    validator = receipt_validator(fixture)
    error = assert_raises(Verdify::CommandError) do
      validator.write!(
        sprint_id: SPRINT,
        controller_ref: "controller/#{SPRINT}",
        receipt_base_sha: fixture[:base]
      )
    end
    assert_includes error.message, "packet base_ref must be dev"
  end

  def test_generator_rejects_unmerged_lane_pr
    fixture = build_fixture
    pull = {
      "number" => PR, "head_sha" => fixture[:report], "head_ref" => "lane/#{LANE}", "base_ref" => "dev",
      "state" => "open", "merged" => false, "merge_commit_sha" => nil
    }
    validator = Verdify::SprintTerminalReceipt.new(
      repo: @root,
      pull_request_loader: ->(_number) { pull },
      check_run_loader: ->(_sha) { trusted_checks(fixture[:report]) }
    )
    error = assert_raises(Verdify::CommandError) do
      validator.write!(
        sprint_id: SPRINT,
        controller_ref: "controller/#{SPRINT}",
        receipt_base_sha: fixture[:base]
      )
    end
    assert_includes error.message, "is not merged"
  end

  def test_controller_tag_cannot_substitute_for_exact_branch
    fixture = build_fixture
    git("branch", "-D", "controller/#{SPRINT}")
    git("tag", "controller/#{SPRINT}", fixture[:outcome])
    validator = receipt_validator(fixture)
    error = assert_raises(Verdify::CommandError) do
      validator.write!(
        sprint_id: SPRINT,
        controller_ref: "controller/#{SPRINT}",
        receipt_base_sha: fixture[:base]
      )
    end
    assert_includes error.message, "controller branch does not exist"
  end

  def test_forged_controller_issue_scope_cannot_override_reviewed_contract
    fixture = build_fixture(controller_issue_ids: [999])
    validator = receipt_validator(fixture)
    error = assert_raises(Verdify::CommandError) do
      validator.write!(
        sprint_id: SPRINT,
        controller_ref: "controller/#{SPRINT}",
        receipt_base_sha: fixture[:base]
      )
    end
    assert_includes error.message, "controller lane artifact differs from canonical reviewed head"
  end

  def test_recovery_mode_is_limited_to_the_exact_bootstrap_sprint_set
    fixture = build_fixture
    validator = receipt_validator(fixture)
    error = assert_raises(Verdify::UsageError) do
      validator.write!(
        sprint_id: SPRINT,
        controller_ref: "controller/#{SPRINT}",
        receipt_base_sha: fixture[:base],
        mode: "recovery"
      )
    end
    assert_includes error.message, "recovery mode is limited"
    assert_equal 6, Verdify::SprintTerminalReceipt::RECOVERY_SPRINT_IDS.length
  end

  private

  def build_fixture(release_integrated: nil, packet_base_ref: "dev", controller_issue_ids: nil)
    @root = Dir.mktmpdir("verdify-terminal-receipt-")
    git("init", "-q", "-b", "main")
    git("config", "user.name", "Verdify Test")
    git("config", "user.email", "verdify-test@example.invalid")
    workflow_root = File.join(@root, ".agent-workflow")
    FileUtils.mkdir_p(workflow_root)
    example_root = Verdify::ROOT.join("examples/minimal-project/.agent-workflow")
    %w[project architecture modules].each do |directory|
      FileUtils.cp_r(example_root.join(directory), File.join(workflow_root, directory))
    end
    File.write(File.join(@root, "README.md"), "# Fixture\n")
    git("add", "README.md", ".agent-workflow")
    git("commit", "-qm", "baseline")
    baseline = sha

    git("checkout", "-qb", "lane/#{LANE}")
    write_dispatch(baseline)
    git("add", ".agent-workflow")
    git("commit", "-qm", "approved dispatch")
    dispatch = sha

    File.write(File.join(@root, "implementation.txt"), "implemented\n")
    git("add", "implementation.txt")
    git("commit", "-qm", "implementation")
    implementation = sha
    write_closeout(baseline, implementation)
    git("add", relative_closeout_path)
    git("commit", "-qm", "worker closeout")
    evidence = sha
    write_critic(implementation, evidence)
    git("add", relative_critic_path)
    git("commit", "-qm", "fresh critic")
    report = sha

    git("checkout", "-qb", "dev", baseline)
    git("merge", "--no-ff", "-qm", "merge lane PR", "lane/#{LANE}")
    merge = sha
    FileUtils.mkdir_p(File.join(@root, "schemas"))
    FileUtils.cp(Verdify::ROOT.join("schemas/sprint-terminal-receipt.schema.yaml"), File.join(@root, "schemas/sprint-terminal-receipt.schema.yaml"))
    git("add", "schemas/sprint-terminal-receipt.schema.yaml")
    git("commit", "-qm", "activate terminal receipt cutover")
    base = sha

    git("checkout", "-qb", "controller/#{SPRINT}", baseline)
    %w[
      sprint-plan.yaml
      release/wave-release-plan.yaml
      lanes/contracts/issue-123-api.contract.yaml
      lanes/closeout/issue-123-api.closeout.yaml
      critic/issue-123-api.critic.yaml
    ].each do |relative|
      source = git_output("show", "#{report}:.agent-workflow/sprints/#{SPRINT}/#{relative}")
      write_relative(".agent-workflow/sprints/#{SPRINT}/#{relative}", source)
    end
    if controller_issue_ids
      controller_contract_path = File.join(@root, relative_contract_path)
      controller_contract = YAML.safe_load(File.read(controller_contract_path), permitted_classes: [], aliases: false)
      controller_contract["issue_ids"] = controller_issue_ids
      File.write(controller_contract_path, YAML.dump(controller_contract))
    end
    git("add", ".agent-workflow")
    git("commit", "-qm", "assemble controller evidence")
    write_packet(report, base_ref: packet_base_ref, issue_ids: controller_issue_ids || [123])
    git("add", relative_packet_path)
    git("commit", "-qm", "packet P")
    packet = sha
    write_release(release_integrated == :baseline ? baseline : merge)
    git("add", relative_release_path)
    git("commit", "-qm", "release R")
    release = sha
    write_outcome
    git("add", relative_outcome_path)
    git("commit", "-qm", "outcome O")
    outcome = sha

    git("checkout", "-qb", "receipt/#{SPRINT}", base)
    {
      baseline: baseline,
      dispatch: dispatch,
      implementation: implementation,
      evidence: evidence,
      report: report,
      merge: merge,
      base: base,
      packet: packet,
      release: release,
      outcome: outcome
    }
  end

  def write_dispatch(baseline)
    example = Verdify::ROOT.join("examples/minimal-project/.agent-workflow/sprints/#{SPRINT}")
    plan = Verdify::SchemaValidator.load_document(example.join("sprint-plan.yaml"))
    plan["baseline_sha"] = baseline
    plan["lanes"].first["branch"] = "lane/#{LANE}"
    write_relative(relative_plan_path, YAML.dump(plan))

    wave = Verdify::SchemaValidator.load_document(example.join("release/wave-release-plan.yaml"))
    wave["github"]["repository"] = "example/test"
    wave["branch_model"]["base_ref"] = "dev"
    wave["github"]["required_checks"] = Verdify::SprintTerminalReceipt::REQUIRED_CHECKS.keys
    write_relative(".agent-workflow/sprints/#{SPRINT}/release/wave-release-plan.yaml", YAML.dump(wave))

    contract = Verdify::SchemaValidator.load_document(example.join("lanes/contracts/#{LANE}.contract.yaml"))
    contract["baseline_sha"] = baseline
    contract["branch"] = "lane/#{LANE}"
    contract["approval"] = { "status" => "approved", "approver" => "owner", "approved_at" => "2026-07-10T00:00:00Z" }
    write_relative(relative_contract_path, YAML.dump(contract))
  end

  def write_closeout(baseline, implementation)
    contract_hash = Digest::SHA256.file(File.join(@root, relative_contract_path)).hexdigest
    closeout = {
      "schema_ref" => "lane-closeout.schema.yaml", "kind" => "LaneCloseout", "schema_version" => "2.0",
      "sprint_id" => SPRINT, "lane_id" => LANE, "status" => "ready_for_critic", "issue_ids" => [123],
      "pull_request" => PR, "baseline_sha" => baseline, "implementation_head_sha" => implementation,
      "validated_head_sha" => implementation, "contract_hash" => contract_hash, "changed_paths" => ["implementation.txt"],
      "validation_results" => [{ "id" => "test", "command" => "true", "exit_status" => 0, "result" => "passed", "executed_at" => "2026-07-10T00:01:00Z", "artifact" => nil }],
      "acceptance_evidence" => [{ "criterion_id" => "LANE-AC-01", "evidence_ids" => ["test"], "assessment" => "satisfied" }],
      "discovered_issues" => [], "residual_risks" => [], "worktree_clean" => true,
      "worker_agent" => "worker-agent", "worker_session_id" => "worker-session", "completed_at" => "2026-07-10T00:02:00Z", "limitations" => []
    }
    write_relative(relative_closeout_path, YAML.dump(closeout))
  end

  def write_critic(implementation, evidence)
    critic = {
      "schema_ref" => "critic-report.schema.yaml", "kind" => "CriticReport", "schema_version" => "2.0",
      "sprint_id" => SPRINT, "lane_id" => LANE, "pull_request" => PR,
      "worker_agent" => "worker-agent", "worker_session_id" => "worker-session", "critic_agent" => "critic-agent",
      "implementation_head_sha" => implementation, "evidence_head_sha" => evidence, "reviewed_head_sha" => evidence,
      "closeout_path" => relative_closeout_path, "closeout_sha256" => Digest::SHA256.file(File.join(@root, relative_closeout_path)).hexdigest,
      "critic_session_id" => "critic-session", "review_worktree" => @root, "outcome" => "approve", "findings" => [],
      "acceptance_assessment" => [{ "criterion_id" => "LANE-AC-01", "assessment" => "satisfied", "evidence" => ["test"] }],
      "evidence_assessment" => ["Exact evidence chain reviewed."], "integration_risks" => [], "residual_risks" => [], "reviewed_at" => "2026-07-10T00:03:00Z"
    }
    write_relative(relative_critic_path, YAML.dump(critic))
  end

  def write_packet(report, base_ref: "dev", issue_ids: [123])
    packet = Verdify::SchemaValidator.load_document(
      Verdify::ROOT.join("examples/minimal-project/.agent-workflow/sprints/#{SPRINT}/review/review-inbox-packet.yaml")
    )
    packet["status"] = "ready"
    packet["scope"]["sprint_id"] = SPRINT
    packet["scope"]["lane_ids"] = [LANE]
    packet["scope"]["issue_ids"] = issue_ids
    packet["traceability"]["repository"] = "example/test"
    packet["traceability"]["base_ref"] = base_ref
    packet["traceability"]["head_ref"] = "controller/#{SPRINT}"
    packet["traceability"]["review_submissions"] = [{ "pull_request" => PR, "review_submission_head_sha" => report, "reviewer_login" => "critic-agent", "reviewer_id" => 1 }]
    packet["pull_requests"].first["identifier"] = "##{PR}"
    packet["evidence_completeness"]["verdict"] = "complete"
    packet["evidence_completeness"]["missing_required"] = []
    packet["evidence_completeness"]["blockers"] = []
    packet["recommendation"]["outcome"] = "approve"
    write_relative(relative_packet_path, YAML.dump(packet))
  end

  def write_release(integrated_sha)
    release = Verdify::SchemaValidator.load_document(
      Verdify::ROOT.join("examples/minimal-project/.agent-workflow/sprints/#{SPRINT}/release/release-verification.yaml")
    )
    release["sprint_id"] = SPRINT
    release["integrated_sha"] = integrated_sha
    release["deployment"]["observed_revision"] = integrated_sha
    write_relative(relative_release_path, YAML.dump(release))
  end

  def write_outcome
    outcome = Verdify::SchemaValidator.load_document(
      Verdify::ROOT.join("examples/minimal-project/.agent-workflow/sprints/#{SPRINT}/outcome/outcome-review.yaml")
    )
    outcome["sprint_id"] = SPRINT
    write_relative(relative_outcome_path, YAML.dump(outcome))
  end

  def receipt_validator(fixture, checks: trusted_checks(fixture[:report]))
    pull = {
      "number" => PR, "head_sha" => fixture[:report], "head_ref" => "lane/#{LANE}", "base_ref" => "dev",
      "state" => "merged", "merged" => true, "merge_commit_sha" => fixture[:merge]
    }
    Verdify::SprintTerminalReceipt.new(
      repo: @root,
      pull_request_loader: ->(_number) { pull },
      check_run_loader: ->(_sha) { checks }
    )
  end

  def generate_and_commit_receipt(fixture, validator)
    receipt = validator.write!(
      sprint_id: SPRINT,
      controller_ref: "controller/#{SPRINT}",
      receipt_base_sha: fixture[:base],
      mode: "normal",
      generator: "test-controller"
    )
    git("add", *Verdify::SprintTerminalReceipt.paths(SPRINT).values)
    git("commit", "-qm", "terminal receipt")
    receipt
  end

  def trusted_checks(head)
    Verdify::SprintTerminalReceipt::REQUIRED_CHECKS.map.with_index do |(name, workflow), index|
      {
        "id" => index + 1, "name" => name, "status" => "completed", "conclusion" => "success",
        "app_slug" => "github-actions", "workflow_path" => workflow, "workflow_event" => "pull_request", "workflow_head_sha" => head,
        "created_at" => "2026-07-10T00:00:00Z", "started_at" => "2026-07-10T00:00:01Z", "completed_at" => "2026-07-10T00:00:02Z"
      }
    end
  end

  def write_relative(relative, content)
    path = File.join(@root, relative)
    FileUtils.mkdir_p(File.dirname(path))
    File.binwrite(path, content)
  end

  def git(*args)
    system("git", "-C", @root, *args, exception: true)
  end

  def git_output(*args)
    IO.popen(["git", "-C", @root, *args], &:read)
  end

  def sha
    git_output("rev-parse", "HEAD").strip
  end

  def relative_plan_path = ".agent-workflow/sprints/#{SPRINT}/sprint-plan.yaml"
  def relative_contract_path = ".agent-workflow/sprints/#{SPRINT}/lanes/contracts/#{LANE}.contract.yaml"
  def relative_closeout_path = ".agent-workflow/sprints/#{SPRINT}/lanes/closeout/#{LANE}.closeout.yaml"
  def relative_critic_path = ".agent-workflow/sprints/#{SPRINT}/critic/#{LANE}.critic.yaml"
  def relative_packet_path = ".agent-workflow/sprints/#{SPRINT}/review/review-inbox-packet.yaml"
  def relative_release_path = ".agent-workflow/sprints/#{SPRINT}/release/release-verification.yaml"
  def relative_outcome_path = ".agent-workflow/sprints/#{SPRINT}/outcome/outcome-review.yaml"
  def plan_path = File.join(@root, relative_plan_path)
  def receipt_path = File.join(@root, Verdify::SprintTerminalReceipt.paths(SPRINT).fetch(:receipt))
end
