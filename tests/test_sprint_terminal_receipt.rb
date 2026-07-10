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

  def test_full_validation_rejects_hand_authored_plan_that_is_not_the_base_status_transition
    fixture = build_fixture
    validator = receipt_validator(fixture)
    generate_and_commit_receipt(fixture, validator)
    rewrite_terminal_commit do |documents, _receipt|
      documents.fetch(:plan)["goal"] = "forged terminal goal"
    end

    result = validator.validate_full(receipt_path: receipt_path, expected_base_sha: fixture[:base], expected_mode: "normal")
    refute result.valid?
    assert result.errors.any? { |error| error.include?("only status changed to complete") }
  end

  def test_full_validation_rejects_local_release_and_outcome_that_diverge_from_controller
    fixture = build_fixture
    validator = receipt_validator(fixture)
    generate_and_commit_receipt(fixture, validator)
    rewrite_terminal_commit do |documents, _receipt|
      documents.fetch(:release).fetch("artifact_identity").first["identifier"] = "forged-artifact"
      documents.fetch(:outcome).fetch("delivered_outcomes")[0] = "Forged delivered outcome."
    end

    result = validator.validate_full(receipt_path: receipt_path, expected_base_sha: fixture[:base], expected_mode: "normal")
    refute result.valid?
    assert result.errors.any? { |error| error.include?("release bytes do not match controller R") }
    assert result.errors.any? { |error| error.include?("outcome bytes do not match controller O") }
  end

  def test_full_validation_requires_canonical_complete_status
    fixture = build_fixture
    validator = receipt_validator(fixture)
    generate_and_commit_receipt(fixture, validator)
    rewrite_terminal_commit do |documents, _receipt|
      documents.fetch(:status)["next_action"] = "Continue without rerouting."
    end

    result = validator.validate_full(receipt_path: receipt_path, expected_base_sha: fixture[:base], expected_mode: "normal")
    refute result.valid?
    assert result.errors.any? { |error| error.include?("status next_action is not canonical") }
  end

  def test_full_validation_rejects_receipt_that_omits_a_protected_base_lane
    fixture = build_fixture
    validator = receipt_validator(fixture)
    generate_and_commit_receipt(fixture, validator)
    base_with_second_lane = add_second_lane_to_base_and_rebuild_receipt

    result = validator.validate_full(receipt_path: receipt_path, expected_base_sha: base_with_second_lane, expected_mode: "normal")
    refute result.valid?
    assert result.errors.any? { |error| error.include?("lane set must equal every protected-base lane contract") }
  end

  def test_full_validation_rejects_newer_in_progress_trusted_check
    fixture = build_fixture
    checks = trusted_checks(fixture[:report])
    checks.find { |check| check["name"] == "validate" }["completed_at"] = "2026-07-10T02:00:00Z"
    checks << checks.find { |check| check["name"] == "validate" }.merge(
      "id" => 99,
      "status" => "in_progress",
      "conclusion" => nil,
      "created_at" => nil,
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

  def test_generator_rejects_complete_packet_with_explicit_blockers
    fixture = build_fixture(packet_blocked: true)
    validator = receipt_validator(fixture)
    error = assert_raises(Verdify::CommandError) do
      validator.write!(sprint_id: SPRINT, controller_ref: "controller/#{SPRINT}", receipt_base_sha: fixture[:base])
    end
    assert_includes error.message, "retains missing evidence, blockers"
  end

  def test_generator_rejects_complete_packet_with_escalated_blocking_question
    fixture = build_fixture(packet_blocking_question: true)
    validator = receipt_validator(fixture)
    error = assert_raises(Verdify::CommandError) do
      validator.write!(sprint_id: SPRINT, controller_ref: "controller/#{SPRINT}", receipt_base_sha: fixture[:base])
    end
    assert_includes error.message, "open blocking questions"
  end

  def test_generator_rejects_failed_migration_and_unready_rollback
    fixture = build_fixture(release_failed: true)
    validator = receipt_validator(fixture)
    error = assert_raises(Verdify::CommandError) do
      validator.write!(sprint_id: SPRINT, controller_ref: "controller/#{SPRINT}", receipt_base_sha: fixture[:base])
    end
    assert_includes error.message, "failed migration"
    assert_includes error.message, "requires a ready rollback"
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

  def test_terminal_pull_request_loader_normalizes_rest_closed_merged_state
    build_fixture
    repo = Verdify::GitRepository.new(@root)
    payload = {
      "state" => "closed", "merged" => true, "merge_commit_sha" => "f" * 40, "draft" => false,
      "head" => { "sha" => "e" * 40, "ref" => "lane/test" },
      "base" => { "ref" => "dev" }, "user" => { "login" => "worker", "id" => 1 }
    }
    repo.define_singleton_method(:github_slug) { "example/test" }
    repo.define_singleton_method(:github_api_json) { |_path| payload }

    evidence = repo.github_terminal_pull_request_evidence(456)
    assert evidence["merged"]
    assert_equal "merged", evidence["state"]
  end

  def test_check_run_loader_hydrates_only_each_required_names_highest_id
    repo = github_repository_fixture
    head = "a" * 40
    checks = [
      raw_check("validate", 10, 101),
      raw_check("validate", 20, 102),
      raw_check("pull-request-policy", 30, 103),
      raw_check("unrelated", 40, 104)
    ]
    requests = []
    repo.define_singleton_method(:github_api_json) do |path|
      requests << path
      if path.include?("/check-runs?")
        { "check_runs" => checks }
      else
        run_id = path[%r{/actions/runs/(\d+)}, 1]
        { "path" => ".github/workflows/run-#{run_id}.yml@refs/heads/dev", "event" => "pull_request", "head_sha" => head }
      end
    end

    evidence = repo.github_check_run_evidence(head, required_names: %w[validate pull-request-policy])

    assert_equal 3, evidence.length
    assert_nil evidence.find { |check| check["id"] == 10 }["workflow_path"]
    assert_equal ".github/workflows/run-102.yml", evidence.find { |check| check["id"] == 20 }["workflow_path"]
    assert_equal [102, 103], requests.filter_map { |path| path[%r{/actions/runs/(\d+)}, 1]&.to_i }
    refute evidence.any? { |check| check["name"] == "unrelated" }
  end

  def test_check_run_loader_deduplicates_shared_selected_workflow_run
    repo = github_repository_fixture
    head = "b" * 40
    checks = [raw_check("delivery-policy", 20, 501), raw_check("critic-gate", 30, 501)]
    requests = []
    repo.define_singleton_method(:github_api_json) do |path|
      requests << path
      path.include?("/check-runs?") ? { "check_runs" => checks } : {
        "path" => ".github/workflows/delivery-gate.yml@refs/heads/dev", "event" => "pull_request", "head_sha" => head
      }
    end

    evidence = repo.github_check_run_evidence(head, required_names: %w[delivery-policy critic-gate])

    assert_equal 2, evidence.length
    assert_equal 1, requests.count { |path| path.include?("/actions/runs/501") }
    assert evidence.all? { |check| check["workflow_path"] == ".github/workflows/delivery-gate.yml" }
  end

  def test_check_run_loader_retains_invalid_id_sets_without_hydration
    repo = github_repository_fixture
    head = "c" * 40
    current_checks = []
    requests = []
    repo.define_singleton_method(:github_api_json) do |path|
      requests << path
      path.include?("/check-runs?") ? { "check_runs" => current_checks } : {
        "path" => ".github/workflows/validate.yml", "event" => "pull_request", "head_sha" => head
      }
    end
    validator = Verdify::SprintTerminalReceipt.new(repo: repo)

    {
      "duplicate" => [raw_check("validate", 8, 601), raw_check("validate", 8, 602)],
      "malformed" => [raw_check("validate", "not-an-id", 603), raw_check("validate", 9, 604)],
      "fractional-float" => [raw_check("validate", 8.75, 605), raw_check("validate", 9, 606)],
      "fractional-string" => [raw_check("validate", "8.75", 607), raw_check("validate", 9, 608)],
      "leading-zero" => [raw_check("validate", "08", 609), raw_check("validate", 9, 610)],
      "explicit-positive" => [raw_check("validate", "+8", 611), raw_check("validate", 9, 612)]
    }.each do |label, fixture|
      current_checks.replace(fixture)
      requests.clear
      evidence = repo.github_check_run_evidence(head, required_names: ["validate"])
      errors = []
      validator.send(:validate_trusted_checks, evidence, PR, head, errors)

      assert_equal 2, evidence.length, label
      refute requests.any? { |path| path.include?("/actions/runs/") }, label
      assert errors.any? { |error| error.include?("uniquely ordered latest trusted validate check") }, label
    end
  end

  def test_trusted_check_validator_rejects_fractional_and_noncanonical_ids
    repo = github_repository_fixture
    head = "d" * 40
    validator = Verdify::SprintTerminalReceipt.new(repo: repo)

    { "fractional-float" => 1.75, "fractional-string" => "1.75", "leading-zero" => "01", "explicit-positive" => "+1" }.each do |label, check_id|
      checks = trusted_checks(head)
      checks.find { |check| check["name"] == "validate" }["id"] = check_id
      errors = []
      validator.send(:validate_trusted_checks, checks, PR, head, errors)

      assert errors.any? { |error| error.include?("uniquely ordered latest trusted validate check") }, label
    end
    assert_equal 12, Verdify::GitRepository.parse_positive_check_id("12")
  end

  def test_six_receipt_evidence_uses_42_requests_below_fail_closed_ceiling
    repo = github_repository_fixture
    required = Verdify::SprintTerminalReceipt::REQUIRED_CHECKS.keys
    run_ids = [701, 702, 703, 704, 704]
    check_payload = required.map.with_index { |name, index| raw_check(name, index + 1, run_ids.fetch(index)) }
    requests = []
    current_head = nil
    repo.define_singleton_method(:github_api_json) do |path|
      requests << path
      case path
      when %r{/pulls/}
        {
          "state" => "closed", "merged" => true, "merge_commit_sha" => "f" * 40, "draft" => false,
          "head" => { "sha" => current_head, "ref" => "lane/test" },
          "base" => { "ref" => "dev" }, "user" => { "login" => "worker", "id" => 1 }
        }
      when %r{/check-runs\?}
        { "check_runs" => check_payload }
      else
        run_id = path[%r{/actions/runs/(\d+)}, 1]
        workflow = run_id == "704" ? ".github/workflows/delivery-gate.yml" : ".github/workflows/run-#{run_id}.yml"
        { "path" => "#{workflow}@refs/heads/dev", "event" => "pull_request", "head_sha" => current_head }
      end
    end

    6.times do |index|
      current_head = format("%040x", index + 1)
      repo.github_terminal_pull_request_evidence(500 + index)
      repo.github_check_run_evidence(current_head, required_names: required)
    end

    assert_equal 12, requests.count { |path| path.include?("/pulls/") }
    assert_equal 6, requests.count { |path| path.include?("/check-runs?") }
    assert_equal 24, requests.count { |path| path.include?("/actions/runs/") }
    assert_equal 42, requests.length
    assert_operator requests.length, :<=, 6 * Verdify::SprintTerminalReceipt::MAX_GITHUB_EVIDENCE_REQUESTS_PER_LANE
  end

  def test_authenticated_api_failure_never_calls_curl_and_only_reports_allowlisted_diagnostics
    repo = github_repository_fixture
    token = "test-token-value-that-must-not-escape"
    response = <<~RESPONSE
      HTTP/2.0 403 Forbidden
      X-RateLimit-Remaining: 0
      X-RateLimit-Resource: core
      X-RateLimit-Reset: 1783722000
      X-GitHub-Request-Id: SAFE:123
      X-Arbitrary-Secret: do-not-report-this

      {"message":"rate limit for #{token}"}
    RESPONSE
    commands = []
    failure_status = command_status(false)
    repo.define_singleton_method(:capture) do |*command, allow_failure: false|
      commands << command
      [response, "gh: forbidden for #{token} (HTTP 403)", failure_status]
    end

    resource = "repos/example/#{token}\nforged-header\u0000\e[31m" + ("x" * 400)
    error = with_gh_token(token) do
      assert_raises(Verdify::CommandError) { repo.github_api_json(resource) }
    end

    assert_equal ["gh"], commands.map(&:first).uniq
    assert_includes error.message, "status=403"
    assert_includes error.message, "rate_remaining=0"
    assert_includes error.message, "rate_resource=core"
    assert_includes error.message, "rate_reset=1783722000"
    assert_includes error.message, "request_id=SAFE:123"
    assert_includes error.message, "[REDACTED]"
    refute_includes error.message, token
    refute_includes error.message, "X-Arbitrary-Secret"
    refute_includes error.message, "do-not-report-this"
    refute_match(/[[:cntrl:]]/, error.message)
    sanitized_resource = error.message[/resource=(.*?); status=/, 1]
    assert sanitized_resource
    assert_operator sanitized_resource.length, :<=, 256
  end

  def test_authenticated_cli_and_invalid_json_failures_sanitize_resource_without_curl
    repo = github_repository_fixture
    token = "resource-token-sentinel"
    resource = "repos/#{token}\nforged\u0000" + ("z" * 400)
    mode = :unavailable
    commands = []
    success_status = command_status(true)
    repo.define_singleton_method(:capture) do |*command, allow_failure: false|
      commands << command
      raise Verdify::CommandError, "gh unavailable for #{token}" if mode == :unavailable

      ["HTTP/2.0 200 OK\n\nnot-json", "", success_status]
    end

    with_gh_token(token) do
      unavailable = assert_raises(Verdify::CommandError) { repo.github_api_json(resource) }
      assert_sanitized_resource(unavailable, token)
      mode = :invalid_json
      invalid_json = assert_raises(Verdify::CommandError) { repo.github_api_json(resource) }
      assert_sanitized_resource(invalid_json, token)
    end
    assert_equal ["gh"], commands.map(&:first).uniq
  end

  def test_api_without_token_preserves_anonymous_curl_compatibility
    repo = github_repository_fixture
    commands = []
    failure_status = command_status(false)
    success_status = command_status(true)
    repo.define_singleton_method(:capture) do |*command, allow_failure: false|
      commands << command
      if command.first == "gh"
        ["", "gh unavailable", failure_status]
      else
        ['{"ok":true}', "", success_status]
      end
    end

    payload = with_gh_token(nil) { repo.github_api_json("repos/example/test") }

    assert_equal({ "ok" => true }, payload)
    assert_equal %w[gh curl], commands.map(&:first)
  end

  def test_api_without_token_still_fails_closed_when_anonymous_read_fails
    repo = github_repository_fixture
    commands = []
    failure_status = command_status(false)
    repo.define_singleton_method(:capture) do |*command, allow_failure: false|
      commands << command
      ["", "public read failed", failure_status]
    end

    error = with_gh_token(nil) do
      assert_raises(Verdify::CommandError) { repo.github_api_json("repos/example/test") }
    end

    assert_equal %w[gh curl], commands.map(&:first)
    assert_includes error.message, "GitHub API request failed"
  end

  def test_receipt_path_parser_returns_the_sprint_segment
    path = ".agent-workflow/sprints/test-sprint/terminal/terminal-receipt.yaml"
    assert_equal "test-sprint", Verdify::SprintTerminalReceipt.sprint_id_from_receipt_path(path)
    assert_nil Verdify::SprintTerminalReceipt.sprint_id_from_receipt_path(".agent-workflow/sprints/test-sprint/terminal/other.yaml")
  end

  private

  def github_repository_fixture
    @root = Dir.mktmpdir("verdify-github-evidence-")
    system("git", "-C", @root, "init", "-q", exception: true)
    repo = Verdify::GitRepository.new(@root)
    repo.define_singleton_method(:github_slug) { "example/test" }
    repo
  end

  def raw_check(name, id, run_id)
    {
      "id" => id,
      "name" => name,
      "status" => "completed",
      "conclusion" => "success",
      "created_at" => "2026-07-10T00:00:00Z",
      "started_at" => "2026-07-10T00:00:01Z",
      "completed_at" => "2026-07-10T00:00:02Z",
      "app" => { "slug" => "github-actions" },
      "details_url" => "https://github.com/example/test/actions/runs/#{run_id}/job/1"
    }
  end

  def command_status(success)
    Object.new.tap { |status| status.define_singleton_method(:success?) { success } }
  end

  def with_gh_token(value)
    previous = ENV["GH_TOKEN"]
    value.nil? ? ENV.delete("GH_TOKEN") : ENV["GH_TOKEN"] = value
    yield
  ensure
    previous.nil? ? ENV.delete("GH_TOKEN") : ENV["GH_TOKEN"] = previous
  end

  def assert_sanitized_resource(error, token)
    refute_includes error.message, token
    refute_match(/[[:cntrl:]]/, error.message)
    resource = error.message[/resource=(.*?); (?:status|message)=/, 1]
    assert resource
    assert_operator resource.length, :<=, 256
  end

  def build_fixture(release_integrated: nil, packet_base_ref: "dev", controller_issue_ids: nil, packet_blocked: false, packet_blocking_question: false, release_failed: false)
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
    write_packet(
      report,
      base_ref: packet_base_ref,
      issue_ids: controller_issue_ids || [123],
      blocked: packet_blocked,
      blocking_question: packet_blocking_question
    )
    git("add", relative_packet_path)
    git("commit", "-qm", "packet P")
    packet = sha
    write_release(release_integrated == :baseline ? baseline : merge, failed: release_failed)
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

  def write_packet(report, base_ref: "dev", issue_ids: [123], blocked: false, blocking_question: false)
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
    packet["evidence_completeness"]["blockers"] = blocked ? ["critical blocker"] : []
    packet["security"]["unresolved_findings"] = blocked ? ["critical authorization defect"] : []
    if blocking_question
      packet.fetch("questions").first["blocking"] = true
      packet.fetch("questions").first["status"] = "escalated"
    end
    packet["recommendation"]["outcome"] = "approve"
    write_relative(relative_packet_path, YAML.dump(packet))
  end

  def write_release(integrated_sha, failed: false)
    release = Verdify::SchemaValidator.load_document(
      Verdify::ROOT.join("examples/minimal-project/.agent-workflow/sprints/#{SPRINT}/release/release-verification.yaml")
    )
    release["sprint_id"] = SPRINT
    release["integrated_sha"] = integrated_sha
    release["deployment"]["observed_revision"] = integrated_sha
    if failed
      release.fetch("migrations").first["result"] = "failed"
      release.fetch("rollback")["ready"] = false
    end
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
      "state" => "closed", "merged" => true, "merge_commit_sha" => fixture[:merge]
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

  def rewrite_terminal_commit
    paths = Verdify::SprintTerminalReceipt.paths(SPRINT)
    documents = %i[plan status release outcome].to_h do |kind|
      [kind, YAML.safe_load(File.read(File.join(@root, paths.fetch(kind))), permitted_classes: [], aliases: false)]
    end
    receipt = YAML.safe_load(File.read(receipt_path), permitted_classes: [], aliases: false)
    yield documents, receipt
    documents.each do |kind, document|
      bytes = YAML.dump(document)
      File.write(File.join(@root, paths.fetch(kind)), bytes)
      receipt.fetch("artifacts")["#{kind}_sha256"] = Digest::SHA256.hexdigest(bytes)
    end
    File.write(receipt_path, YAML.dump(receipt))
    git("add", *paths.values)
    git("commit", "--amend", "-qm", "hand-authored terminal receipt")
  end

  def add_second_lane_to_base_and_rebuild_receipt
    paths = Verdify::SprintTerminalReceipt.paths(SPRINT)
    saved = %i[status release outcome receipt].to_h do |kind|
      path = kind == :receipt ? receipt_path : File.join(@root, paths.fetch(kind))
      [kind, YAML.safe_load(File.read(path), permitted_classes: [], aliases: false)]
    end

    git("checkout", "-q", "dev")
    plan = YAML.safe_load(File.read(plan_path), permitted_classes: [], aliases: false)
    second_plan_lane = Marshal.load(Marshal.dump(plan.fetch("lanes").first))
    second_plan_lane["lane_id"] = "issue-124-ui"
    second_plan_lane["issue_ids"] = [124]
    second_plan_lane["contract_path"] = ".agent-workflow/sprints/#{SPRINT}/lanes/contracts/issue-124-ui.contract.yaml"
    second_plan_lane["branch"] = "lane/issue-124-ui"
    plan.fetch("lanes") << second_plan_lane
    File.write(plan_path, YAML.dump(plan))

    contract = YAML.safe_load(File.read(File.join(@root, relative_contract_path)), permitted_classes: [], aliases: false)
    contract["lane_id"] = "issue-124-ui"
    contract["issue_ids"] = [124]
    contract["branch"] = "lane/issue-124-ui"
    second_contract_path = ".agent-workflow/sprints/#{SPRINT}/lanes/contracts/issue-124-ui.contract.yaml"
    write_relative(second_contract_path, YAML.dump(contract))
    git("add", relative_plan_path, second_contract_path)
    git("commit", "-qm", "add second protected-base lane")
    new_base = sha

    git("checkout", "-q", "receipt/#{SPRINT}")
    git("reset", "-q", "--hard", new_base)
    plan["status"] = "complete"
    terminal_documents = { plan: plan, status: saved.fetch(:status), release: saved.fetch(:release), outcome: saved.fetch(:outcome) }
    receipt = saved.fetch(:receipt)
    receipt["receipt_base_sha"] = new_base
    terminal_documents.each do |kind, document|
      bytes = YAML.dump(document)
      write_relative(paths.fetch(kind), bytes)
      receipt.fetch("artifacts")["#{kind}_sha256"] = Digest::SHA256.hexdigest(bytes)
    end
    write_relative(paths.fetch(:receipt), YAML.dump(receipt))
    git("add", *paths.values)
    git("commit", "-qm", "receipt omitting second protected-base lane")
    new_base
  end

  def trusted_checks(head)
    Verdify::SprintTerminalReceipt::REQUIRED_CHECKS.map.with_index do |(name, workflow), index|
      {
        "id" => index + 1, "name" => name, "status" => "completed", "conclusion" => "success",
        "app_slug" => "github-actions", "workflow_path" => workflow, "workflow_event" => "pull_request", "workflow_head_sha" => head,
        "created_at" => nil, "started_at" => "2026-07-10T00:00:01Z", "completed_at" => "2026-07-10T00:00:02Z"
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
