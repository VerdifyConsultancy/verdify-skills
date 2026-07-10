# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "minitest/autorun"
require "tmpdir"
require "yaml"
require_relative "../lib/verdify"

class LaneReviewValidatorTest < Minitest::Test
  def test_committed_file_snapshot_uses_byte_identity_for_unicode
    root = Dir.mktmpdir("verdify-unicode-snapshot-")
    git(root, "init", "-q", "-b", "main")
    git(root, "config", "user.name", "Verdify Test")
    git(root, "config", "user.email", "verdify-test@example.invalid")
    path = File.join(root, "evidence.txt")
    File.write(path, "I → E → S\n")
    git(root, "add", "evidence.txt")
    git(root, "commit", "-qm", "unicode evidence")

    assert_equal File.binread(path), Verdify::GitRepository.new(root).file_at("HEAD", "evidence.txt")
  ensure
    FileUtils.rm_rf(root) if root
  end

  def test_accepts_non_self_referential_implementation_evidence_report_chain
    chain = build_chain
    result = validator(chain).validate_critic(tip_sha: chain[:report_head])

    assert result.valid?, result.errors.join("\n")
    assert_equal chain[:implementation_head], result.implementation_head_sha
    assert_equal chain[:evidence_head], result.evidence_head_sha
    assert_equal chain[:report_head], result.critic_report_head_sha

    submitted = validator(chain).validate_submission(
      result: result,
      review_submission_head_sha: chain[:report_head],
      expected_reviewer_login: "reviewer",
      expected_reviewer_id: 2,
      reviewer_permission: "admin",
      pull_request_head_sha: chain[:report_head],
      pull_request_author: "worker",
      pull_request_author_id: 1,
      submitted_reviews: [
        { "id" => 1, "state" => "APPROVED", "commit_id" => chain[:report_head], "reviewer" => "reviewer", "reviewer_id" => 2, "submitted_at" => "2026-07-09T00:04:00Z" }
      ]
    )
    assert submitted.valid?, submitted.errors.join("\n")
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_transport_neutral_critic_status_accepts_only_approving_current_report_head
    chain = build_chain
    review_validator = validator(chain)
    result = review_validator.validate_critic(tip_sha: chain[:report_head])
    status = review_validator.validate_critic_status(result: result, pull_request_head_sha: chain[:report_head])
    assert status.valid?, status.errors.join("\n")

    stale = review_validator.validate_critic_status(result: result, pull_request_head_sha: "f" * 40)
    refute stale.valid?
    assert stale.errors.any? { |error| error.include?("critic report head") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_transport_neutral_critic_status_rejects_non_approving_outcome
    chain = build_chain(critic_outcome: "request_fixes")
    review_validator = validator(chain)
    result = review_validator.validate_critic(tip_sha: chain[:report_head])
    status = review_validator.validate_critic_status(result: result, pull_request_head_sha: chain[:report_head])
    refute status.valid?
    assert status.errors.any? { |error| error.include?("critic outcome") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_rejects_self_review_without_lease_state
    chain = build_chain(critic_session_id: "worker-session")
    result = validator(chain).validate_critic(tip_sha: chain[:report_head])

    refute result.valid?
    assert result.errors.any? { |error| error.include?("critic session must differ from worker session") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_rejects_same_worker_and_critic_agent
    chain = build_chain(critic_agent: "worker-agent")
    result = validator(chain).validate_critic(tip_sha: chain[:report_head])

    refute result.valid?
    assert result.errors.any? { |error| error.include?("critic agent must differ from worker agent") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_rejects_non_ready_closeout
    chain = build_chain(closeout_status: "blocked")
    result = validator(chain).validate_critic(tip_sha: chain[:report_head])

    refute result.valid?
    assert result.errors.any? { |error| error.include?("closeout status must be ready_for_critic") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_rejects_substantive_change_in_worker_evidence_suffix
    chain = build_chain(extra_worker_evidence_path: true)
    result = validator(chain).validate_critic(tip_sha: chain[:report_head])

    refute result.valid?
    assert result.errors.any? { |error| error.include?("worker evidence commit") && error.include?("unexpected.txt") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_rejects_mismatched_closeout_digest
    chain = build_chain(closeout_sha256: "0" * 64)
    result = validator(chain).validate_critic(tip_sha: chain[:report_head])

    refute result.valid?
    assert result.errors.any? { |error| error.include?("closeout_sha256") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_rejects_dirty_contract_that_differs_from_implementation_snapshot
    chain = build_chain
    File.open(chain[:contract_path], "a") { |file| file << "# uncommitted scope mutation\n" }
    result = validator(chain).validate_critic(tip_sha: chain[:report_head])

    refute result.valid?
    assert result.errors.any? { |error| error.include?("working lane contract does not match implementation_head_sha") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_rejects_dispatch_policy_mutation_during_implementation
    chain = build_chain(mutate_dispatch_during_implementation: true)
    result = validator(chain).validate_critic(tip_sha: chain[:report_head])

    refute result.valid?
    assert result.errors.any? { |error| error.include?("approved dispatch artifacts changed after the dispatch commit") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_rejects_critic_implementation_head_mismatch
    chain = build_chain
    critic = YAML.safe_load(File.read(chain[:critic_path]), permitted_classes: [], aliases: false)
    critic["implementation_head_sha"] = git(chain[:root], "rev-parse", "HEAD~3").strip
    File.write(chain[:critic_path], YAML.dump(critic))
    result = validator(chain).validate_critic(tip_sha: chain[:report_head])

    refute result.valid?
    assert result.errors.any? { |error| error.include?("critic implementation_head_sha must match") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_rejects_reviewed_head_that_differs_from_evidence_head
    chain = build_chain
    critic = YAML.safe_load(File.read(chain[:critic_path]), permitted_classes: [], aliases: false)
    critic["reviewed_head_sha"] = chain[:implementation_head]
    File.write(chain[:critic_path], YAML.dump(critic))
    result = validator(chain).validate_critic(tip_sha: chain[:report_head])

    refute result.valid?
    assert result.errors.any? { |error| error.include?("reviewed_head_sha must equal evidence_head_sha") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_rejects_non_ancestor_evidence_head
    chain = build_chain
    critic = YAML.safe_load(File.read(chain[:critic_path]), permitted_classes: [], aliases: false)
    critic["evidence_head_sha"] = git(chain[:root], "rev-parse", "HEAD~3").strip
    critic["reviewed_head_sha"] = critic["evidence_head_sha"]
    File.write(chain[:critic_path], YAML.dump(critic))
    result = validator(chain).validate_critic(tip_sha: chain[:report_head])

    refute result.valid?
    assert result.errors.any? { |error| error.include?("worker evidence head must descend from its source head") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_rejects_merge_commit_in_worker_evidence_suffix
    chain = build_chain(worker_evidence_merge: true)
    result = validator(chain).validate_critic(tip_sha: chain[:report_head])

    refute result.valid?
    assert result.errors.any? { |error| error.include?("worker evidence suffix contains merge commit") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_rejects_substantive_change_in_critic_evidence_suffix
    chain = build_chain(extra_critic_evidence_path: true)
    result = validator(chain).validate_critic(tip_sha: chain[:report_head])

    refute result.valid?
    assert result.errors.any? { |error| error.include?("critic evidence commit") && error.include?("critic-unexpected.txt") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_rejects_stale_or_missing_commit_bound_submission
    chain = build_chain(post_review_change: true)
    result = validator(chain).validate_critic(tip_sha: chain[:post_review_head])
    assert result.valid?, result.errors.join("\n")

    stale = validator(chain).validate_submission(
      result: result,
      review_submission_head_sha: chain[:report_head],
      expected_reviewer_login: "reviewer",
      expected_reviewer_id: 2,
      reviewer_permission: "admin",
      pull_request_head_sha: chain[:post_review_head],
      pull_request_author: "worker",
      pull_request_author_id: 1,
      submitted_reviews: []
    )
    refute stale.valid?
    assert stale.errors.any? { |error| error.include?("live pull request head") }
    assert stale.errors.any? { |error| error.include?("no commit-bound GitHub review") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_latest_effective_review_must_be_independent_admin_approval
    chain = build_chain
    result = validator(chain).validate_critic(tip_sha: chain[:report_head])
    reversed = validator(chain).validate_submission(
      result: result,
      review_submission_head_sha: chain[:report_head],
      expected_reviewer_login: "reviewer",
      expected_reviewer_id: 2,
      reviewer_permission: "admin",
      pull_request_head_sha: chain[:report_head],
      pull_request_author: "worker",
      pull_request_author_id: 1,
      submitted_reviews: [
        { "id" => 1, "state" => "APPROVED", "commit_id" => chain[:report_head], "reviewer" => "reviewer", "reviewer_id" => 2, "submitted_at" => "2026-07-09T00:04:00Z" },
        { "id" => 2, "state" => "CHANGES_REQUESTED", "commit_id" => chain[:report_head], "reviewer" => "reviewer", "reviewer_id" => 2, "submitted_at" => "2026-07-09T00:05:00Z" }
      ]
    )

    refute reversed.valid?
    assert reversed.errors.any? { |error| error.include?("no commit-bound GitHub review") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_change_request_from_another_reviewer_blocks_recorded_approval
    chain = build_chain
    result = validator(chain).validate_critic(tip_sha: chain[:report_head])
    blocked = validator(chain).validate_submission(
      result: result,
      review_submission_head_sha: chain[:report_head],
      expected_reviewer_login: "reviewer-a",
      expected_reviewer_id: 2,
      reviewer_permission: "admin",
      pull_request_head_sha: chain[:report_head],
      pull_request_author: "worker",
      pull_request_author_id: 1,
      submitted_reviews: [
        { "id" => 1, "state" => "APPROVED", "commit_id" => chain[:report_head], "reviewer" => "reviewer-a", "reviewer_id" => 2, "submitted_at" => "2026-07-09T00:04:00Z" },
        { "id" => 2, "state" => "CHANGES_REQUESTED", "commit_id" => chain[:report_head], "reviewer" => "reviewer-b", "reviewer_id" => 3, "submitted_at" => "2026-07-09T00:05:00Z" }
      ]
    )

    refute blocked.valid?
    assert blocked.errors.any? { |error| error.include?("effective change-request review remains unresolved") && error.include?("reviewer-b") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_dismissed_review_from_another_reviewer_does_not_block_recorded_approval
    chain = build_chain
    result = validator(chain).validate_critic(tip_sha: chain[:report_head])
    submitted = validator(chain).validate_submission(
      result: result,
      review_submission_head_sha: chain[:report_head],
      expected_reviewer_login: "reviewer-a",
      expected_reviewer_id: 2,
      reviewer_permission: "admin",
      pull_request_head_sha: chain[:report_head],
      pull_request_author: "worker",
      pull_request_author_id: 1,
      submitted_reviews: [
        { "id" => 1, "state" => "APPROVED", "commit_id" => chain[:report_head], "reviewer" => "reviewer-a", "reviewer_id" => 2, "submitted_at" => "2026-07-09T00:04:00Z" },
        { "id" => 2, "state" => "DISMISSED", "commit_id" => chain[:report_head], "reviewer" => "reviewer-b", "reviewer_id" => 3, "submitted_at" => "2026-07-09T00:05:00Z" }
      ]
    )

    assert submitted.valid?, submitted.errors.join("\n")
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_later_comment_does_not_revoke_commit_bound_approval
    chain = build_chain
    result = validator(chain).validate_critic(tip_sha: chain[:report_head])
    submitted = validator(chain).validate_submission(
      result: result,
      review_submission_head_sha: chain[:report_head],
      expected_reviewer_login: "reviewer",
      expected_reviewer_id: 2,
      reviewer_permission: "admin",
      pull_request_head_sha: chain[:report_head],
      pull_request_author: "worker",
      pull_request_author_id: 1,
      submitted_reviews: [
        { "id" => 1, "state" => "APPROVED", "commit_id" => chain[:report_head], "reviewer" => "reviewer", "submitted_at" => "2026-07-09T00:04:00Z" },
        { "id" => 2, "state" => "COMMENTED", "commit_id" => chain[:report_head], "reviewer" => "reviewer", "submitted_at" => "2026-07-09T00:05:00Z" }
      ]
    )

    assert submitted.valid?, submitted.errors.join("\n")
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_required_check_uses_newest_start_not_latest_completion
    checks = [
      { "id" => 1, "name" => "validate", "status" => "COMPLETED", "conclusion" => "SUCCESS", "started_at" => "2026-07-09T10:00:00Z", "completed_at" => "2026-07-09T10:06:00Z" },
      { "id" => 2, "name" => "validate", "status" => "IN_PROGRESS", "conclusion" => nil, "started_at" => "2026-07-09T10:05:00Z", "completed_at" => nil }
    ]

    refute Verdify::CLI.new([]).send(:required_checks_succeed?, checks, ["validate"])
    checks.last["status"] = "COMPLETED"
    checks.last["conclusion"] = "FAILURE"
    checks.last["completed_at"] = "2026-07-09T10:07:00Z"
    refute Verdify::CLI.new([]).send(:required_checks_succeed?, checks, ["validate"])
    checks.last["conclusion"] = "SUCCESS"
    assert Verdify::CLI.new([]).send(:required_checks_succeed?, checks, ["validate"])
  end

  def test_delivery_phase_state_table
    cli = Verdify::CLI.new([])
    assert_equal "pre_integration", cli.send(:delivery_phase, nil)
    assert_equal "pre_integration", cli.send(:delivery_phase, { "status" => "pending" })
    assert_equal "pre_integration", cli.send(:delivery_phase, { "status" => "integration_failed" })
    %w[ready_for_deployment deployment_failed rolled_back verified].each do |status|
      assert_equal "post_integration", cli.send(:delivery_phase, { "status" => status })
    end
  end

  def test_github_pull_request_evidence_parses_live_shapes
    chain = build_chain(route_ready: true, lane_branch: "lane/issue-123-api")
    prepare_controller_packet(chain, github_remote: true)
    with_fake_gh(chain) do
      repo = Verdify::GitRepository.new(chain[:root])
      pull = repo.github_pull_request_evidence(456)
      permission = repo.github_collaborator_permission("human-reviewer")

      assert_equal chain[:report_head], pull["head_sha"]
      assert_equal "lane/issue-123-api", pull["head_ref"]
      assert_equal "main", pull["base_ref"]
      assert_equal "validate", pull["checks"].first["name"]
      assert_equal "2026-07-09T00:05:00Z", pull["checks"].first["started_at"]
      assert_equal chain[:report_head], pull["reviews"].first["commit_id"]
      assert_equal 1, pull["author_id"]
      assert_equal({ "permission" => "admin", "login" => "human-reviewer", "id" => 12_345 }, permission)
    end
  ensure
    cleanup_chain(chain)
  end

  def test_github_pull_request_evidence_rejects_missing_or_changed_head
    chain = build_chain(route_ready: true, lane_branch: "lane/issue-123-api")
    prepare_controller_packet(chain, github_remote: true)
    missing = default_gh_fixture(chain)
    missing["pulls"].each { |pull| pull["head"]["sha"] = nil }
    missing["pr_view"]["headRefOid"] = nil
    with_fake_gh(chain, missing) do
      error = assert_raises(Verdify::CommandError) { Verdify::GitRepository.new(chain[:root]).github_pull_request_evidence(456) }
      assert_includes error.message, "changed or was missing"
    end

    changed = default_gh_fixture(chain)
    changed["pulls"].last["head"]["sha"] = "f" * 40
    with_fake_gh(chain, changed) do
      error = assert_raises(Verdify::CommandError) { Verdify::GitRepository.new(chain[:root]).github_pull_request_evidence(456) }
      assert_includes error.message, "changed or was missing"
    end
  ensure
    cleanup_chain(chain)
  end

  def test_route_reaches_ready_for_integration_from_controller_only_clone
    chain = build_chain(route_ready: true, lane_branch: "lane/issue-123-api")
    prepare_controller_packet(chain, github_remote: true, delete_local_lane: true)
    stdout = nil
    stderr = nil
    status = nil
    with_fake_gh(chain) do
      stdout, stderr = capture_io do
        status = Verdify::CLI.run(["route", "--repo", chain[:root], "--json"])
      end
    end

    assert_equal 0, status, stderr
    decision = JSON.parse(stdout)
    assert_equal "READY_FOR_INTEGRATION", decision["current_state"]
    assert_equal "release-verification", decision["next_skill"]
    assert_equal "integration", decision["next_mode"]
  ensure
    cleanup_chain(chain)
  end

  def test_route_accepts_transport_neutral_critic_status_for_dev_without_github_approval
    chain = build_chain(route_ready: true, lane_branch: "lane/issue-123-api", integration_base: "dev")
    prepare_controller_packet(chain, github_remote: true, delete_local_lane: true)
    fixture = default_gh_fixture(chain)
    fixture["pr_view"]["reviews"] = []
    fixture["pr_view"]["statusCheckRollup"] << fixture["pr_view"]["statusCheckRollup"].first.merge(
      "databaseId" => 101,
      "name" => "critic-gate",
      "workflowName" => "delivery-gate"
    )
    stdout = nil
    with_fake_gh(chain, fixture) do
      stdout, = capture_io { Verdify::CLI.run(["route", "--repo", chain[:root], "--json"]) }
    end
    decision = JSON.parse(stdout)
    assert_equal "READY_FOR_INTEGRATION", decision["current_state"]
    assert_includes decision["reason"], "transport-neutral critic status"
  ensure
    cleanup_chain(chain)
  end

  def test_route_rejects_wrong_reviewer_identity_and_missing_required_check
    chain = build_chain(route_ready: true, lane_branch: "lane/issue-123-api")
    prepare_controller_packet(chain, github_remote: true)
    identity_fixture = default_gh_fixture(chain)
    identity_fixture["permission"]["user"]["id"] = 99_999
    identity_stdout = nil
    with_fake_gh(chain, identity_fixture) do
      identity_stdout, = capture_io { Verdify::CLI.run(["route", "--repo", chain[:root], "--json"]) }
    end
    identity_decision = JSON.parse(identity_stdout)
    assert_equal "LANE_REVIEW_SUBMISSION_UNVERIFIED", identity_decision["current_state"]
    assert identity_decision["evidence"].any? { |item| item["finding"].include?("reviewer identity") }

    check_fixture = default_gh_fixture(chain)
    check_fixture["pr_view"]["statusCheckRollup"] = []
    check_stdout = nil
    with_fake_gh(chain, check_fixture) do
      check_stdout, = capture_io { Verdify::CLI.run(["route", "--repo", chain[:root], "--json"]) }
    end
    check_decision = JSON.parse(check_stdout)
    assert_equal "LANE_REVIEW_SUBMISSION_UNVERIFIED", check_decision["current_state"]
    assert check_decision["evidence"].any? { |item| item["finding"].include?("checks") }
  ensure
    cleanup_chain(chain)
  end

  def test_route_reaches_ready_for_critic_from_controller_only_clone
    chain = build_chain(route_ready: true, lane_branch: "lane/issue-123-api")
    git(chain[:root], "checkout", "-q", "main")
    git(chain[:root], "branch", "-f", chain[:lane_branch], chain[:evidence_head])
    chain[:pr_head] = chain[:evidence_head]
    prepare_controller_packet(chain, github_remote: true, delete_local_lane: true)
    stdout = nil
    with_fake_gh(chain) do
      stdout, = capture_io { Verdify::CLI.run(["route", "--repo", chain[:root], "--json"]) }
    end

    decision = JSON.parse(stdout)
    assert_equal "LANE_READY_FOR_CRITIC", decision["current_state"]
    assert_equal "independent-critic", decision["next_skill"]
  ensure
    cleanup_chain(chain)
  end

  def test_route_advances_through_merged_release_and_outcome_suffix
    chain = build_chain(route_ready: true, lane_branch: "lane/issue-123-api")
    prepare_controller_packet(chain, github_remote: true)
    git(chain[:root], "checkout", "-q", "main")
    git(chain[:root], "merge", "--no-ff", "-qm", "integrate approved lane", chain[:lane_branch])
    integrated_sha = git(chain[:root], "rev-parse", "HEAD").strip
    git(chain[:root], "push", "-q", "origin", "main")
    git(chain[:root], "checkout", "-q", "controller/2026-06-22-a")

    release_path = File.join(chain[:root], ".agent-workflow/sprints/2026-06-22-a/release/release-verification.yaml")
    release = Verdify::SchemaValidator.load_document(
      Verdify::ROOT.join("examples/minimal-project/.agent-workflow/sprints/2026-06-22-a/release/release-verification.yaml")
    )
    release["integrated_sha"] = integrated_sha
    release["deployment"]["observed_revision"] = integrated_sha
    File.write(release_path, YAML.dump(release))
    git(chain[:root], "add", release_path)
    git(chain[:root], "commit", "-qm", "record verified release")
    git(chain[:root], "push", "-q", "origin", "HEAD")

    fixture = default_gh_fixture(chain)
    fixture["pulls"].each do |pull|
      pull["merged"] = true
      pull["merge_commit_sha"] = integrated_sha
    end
    fixture["pr_view"]["state"] = "MERGED"
    fixture["pr_view"]["mergeStateStatus"] = "UNKNOWN"
    first_stdout = nil
    with_fake_gh(chain, fixture) do
      first_stdout, = capture_io { Verdify::CLI.run(["route", "--repo", chain[:root], "--json"]) }
    end
    assert_equal "OUTCOME_REVIEW_REQUIRED", JSON.parse(first_stdout)["current_state"]

    outcome_path = File.join(chain[:root], ".agent-workflow/sprints/2026-06-22-a/outcome/outcome-review.yaml")
    FileUtils.mkdir_p(File.dirname(outcome_path))
    FileUtils.cp(
      Verdify::ROOT.join("examples/minimal-project/.agent-workflow/sprints/2026-06-22-a/outcome/outcome-review.yaml"),
      outcome_path
    )
    git(chain[:root], "add", outcome_path)
    git(chain[:root], "commit", "-qm", "record accepted outcome")
    git(chain[:root], "push", "-q", "origin", "HEAD")
    final_stdout = nil
    with_fake_gh(chain, fixture) do
      final_stdout, = capture_io { Verdify::CLI.run(["route", "--repo", chain[:root], "--json"]) }
    end
    assert_equal "SPRINT_COMPLETE", JSON.parse(final_stdout)["current_state"]
  ensure
    cleanup_chain(chain)
  end

  def test_rejects_approval_from_pr_author_or_non_maintainer
    chain = build_chain
    result = validator(chain).validate_critic(tip_sha: chain[:report_head])
    self_approval = validator(chain).validate_submission(
      result: result,
      review_submission_head_sha: chain[:report_head],
      expected_reviewer_login: "worker",
      expected_reviewer_id: 1,
      reviewer_permission: "write",
      pull_request_head_sha: chain[:report_head],
      pull_request_author: "worker",
      pull_request_author_id: 1,
      submitted_reviews: [
        { "id" => "review-1", "state" => "APPROVED", "commit_id" => chain[:report_head], "reviewer" => "worker", "submitted_at" => "2026-07-09T00:04:00Z" }
      ]
    )

    refute self_approval.valid?
    assert self_approval.errors.any? { |error| error.include?("independent repository admin or maintainer") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_route_does_not_advance_on_approve_outcome_with_invalid_evidence_chain
    chain = build_chain(closeout_sha256: "0" * 64, route_ready: true)
    status = nil
    stdout, stderr = capture_io do
      status = Verdify::CLI.run(["route", "--repo", chain[:root], "--json"])
    end

    assert_equal 0, status, stderr
    decision = JSON.parse(stdout)
    assert_equal "LANE_REVIEW_EVIDENCE_INVALID", decision["current_state"]
    refute_equal "release-verification", decision["next_skill"]
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_route_requires_exact_planned_lane_and_contract_set
    chain = build_chain(route_ready: true)
    extra_contract_path = File.join(chain[:root], ".agent-workflow/sprints/2026-06-22-a/lanes/contracts/unplanned-lane.contract.yaml")
    contract = YAML.safe_load(File.read(chain[:contract_path]), permitted_classes: [], aliases: false)
    contract["lane_id"] = "unplanned-lane"
    contract["issue_ids"] = [999]
    File.write(extra_contract_path, YAML.dump(contract))
    git(chain[:root], "add", extra_contract_path)
    git(chain[:root], "commit", "-qm", "commit unplanned lane contract")
    status = nil
    stdout, stderr = capture_io do
      status = Verdify::CLI.run(["route", "--repo", chain[:root], "--json"])
    end

    assert_equal 0, status, stderr
    assert_equal "LANE_TRANSACTION_INCOMPLETE", JSON.parse(stdout)["current_state"]
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_route_requires_contract_branch_to_match_sprint_plan
    chain = build_chain(route_ready: true)
    contract = YAML.safe_load(File.read(chain[:contract_path]), permitted_classes: [], aliases: false)
    contract["branch"] = "lane/different-branch"
    File.write(chain[:contract_path], YAML.dump(contract))
    git(chain[:root], "add", chain[:contract_path])
    git(chain[:root], "commit", "-qm", "commit mismatched lane branch")
    status = nil
    stdout, stderr = capture_io do
      status = Verdify::CLI.run(["route", "--repo", chain[:root], "--json"])
    end

    assert_equal 0, status, stderr
    assert_equal "LANE_TRANSACTION_INCOMPLETE", JSON.parse(stdout)["current_state"]
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_route_requires_contract_sprint_to_match_active_sprint
    chain = build_chain(route_ready: true)
    contract = YAML.safe_load(File.read(chain[:contract_path]), permitted_classes: [], aliases: false)
    contract["sprint_id"] = "different-sprint"
    File.write(chain[:contract_path], YAML.dump(contract))
    git(chain[:root], "add", chain[:contract_path])
    git(chain[:root], "commit", "-qm", "commit mismatched sprint identity")
    status = nil
    stdout, stderr = capture_io do
      status = Verdify::CLI.run(["route", "--repo", chain[:root], "--json"])
    end

    assert_equal 0, status, stderr
    assert_equal "LANE_TRANSACTION_INCOMPLETE", JSON.parse(stdout)["current_state"]
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_route_rejects_uncommitted_sprint_plan_before_selection
    chain = build_chain(route_ready: true)
    plan_path = File.join(chain[:root], ".agent-workflow/sprints/2026-06-22-a/sprint-plan.yaml")
    plan = YAML.safe_load(File.read(plan_path), permitted_classes: [], aliases: false)
    plan["status"] = "complete"
    File.write(plan_path, YAML.dump(plan))
    status = nil
    stdout, stderr = capture_io do
      status = Verdify::CLI.run(["route", "--repo", chain[:root], "--json"])
    end

    assert_equal 0, status, stderr
    assert_equal "SPRINT_TRANSACTION_UNCOMMITTED", JSON.parse(stdout)["current_state"]
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_route_rejects_deleted_active_sprint_plan_before_selection
    chain = build_chain(route_ready: true)
    FileUtils.rm_f(File.join(chain[:root], ".agent-workflow/sprints/2026-06-22-a/sprint-plan.yaml"))
    status = nil
    stdout, stderr = capture_io do
      status = Verdify::CLI.run(["route", "--repo", chain[:root], "--json"])
    end

    assert_equal 0, status, stderr
    assert_equal "SPRINT_TRANSACTION_UNCOMMITTED", JSON.parse(stdout)["current_state"]
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_route_rejects_uncommitted_completion_status_before_selection
    chain = build_chain(route_ready: true)
    status_path = File.join(chain[:root], ".agent-workflow/sprints/2026-06-22-a/status.yaml")
    File.write(status_path, YAML.dump({ "state" => "COMPLETE" }))
    status = nil
    stdout, stderr = capture_io do
      status = Verdify::CLI.run(["route", "--repo", chain[:root], "--json"])
    end

    assert_equal 0, status, stderr
    assert_equal "SPRINT_TRANSACTION_UNCOMMITTED", JSON.parse(stdout)["current_state"]
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_route_rejects_dirty_open_gate_status
    chain = build_chain(route_ready: true)
    gate_path = File.join(chain[:root], ".agent-workflow/sprints/2026-06-22-a/gates/blocker.yaml")
    FileUtils.mkdir_p(File.dirname(gate_path))
    gate = valid_gate("blocker", "2026-06-22-a", "open")
    File.write(gate_path, YAML.dump(gate))
    git(chain[:root], "add", gate_path)
    git(chain[:root], "commit", "-qm", "record open gate")
    gate["status"] = "approved"
    gate["decision"] = "continue"
    gate["rationale"] = "Uncommitted bypass attempt."
    gate["resolved_at"] = "2026-07-09T00:11:00Z"
    File.write(gate_path, YAML.dump(gate))
    stdout, = capture_io { Verdify::CLI.run(["route", "--repo", chain[:root], "--json"]) }

    assert_equal "GATE_STATE_UNCOMMITTED", JSON.parse(stdout)["current_state"]
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_route_rejects_deleted_committed_gate
    chain = build_chain(route_ready: true)
    gate_path = File.join(chain[:root], ".agent-workflow/sprints/2026-06-22-a/gates/blocker.yaml")
    FileUtils.mkdir_p(File.dirname(gate_path))
    File.write(gate_path, YAML.dump(valid_gate("blocker", "2026-06-22-a", "open")))
    git(chain[:root], "add", gate_path)
    git(chain[:root], "commit", "-qm", "record open gate")
    FileUtils.rm_f(gate_path)
    stdout, = capture_io { Verdify::CLI.run(["route", "--repo", chain[:root], "--json"]) }

    assert_equal "GATE_STATE_UNCOMMITTED", JSON.parse(stdout)["current_state"]
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_route_rejects_committed_complete_status_for_active_plan
    chain = build_chain(route_ready: true)
    status_path = File.join(chain[:root], ".agent-workflow/sprints/2026-06-22-a/status.yaml")
    File.write(status_path, YAML.dump(valid_sprint_status("2026-06-22-a", "COMPLETE")))
    git(chain[:root], "add", status_path)
    git(chain[:root], "commit", "-qm", "attempt premature sprint completion")
    status = nil
    stdout, stderr = capture_io do
      status = Verdify::CLI.run(["route", "--repo", chain[:root], "--json"])
    end

    assert_equal 0, status, stderr
    assert_equal "SPRINT_PLAN_INVALID", JSON.parse(stdout)["current_state"]
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_route_rejects_cross_sprint_status_identity
    chain = build_chain(route_ready: true)
    status_path = File.join(chain[:root], ".agent-workflow/sprints/2026-06-22-a/status.yaml")
    File.write(status_path, YAML.dump(valid_sprint_status("different-sprint", "IMPLEMENTING")))
    git(chain[:root], "add", status_path)
    git(chain[:root], "commit", "-qm", "commit cross-sprint status")
    status = nil
    stdout, stderr = capture_io do
      status = Verdify::CLI.run(["route", "--repo", chain[:root], "--json"])
    end

    assert_equal 0, status, stderr
    assert_equal "SPRINT_PLAN_INVALID", JSON.parse(stdout)["current_state"]
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_route_rejects_plan_sprint_id_that_differs_from_directory
    chain = build_chain(route_ready: true)
    plan_path = File.join(chain[:root], ".agent-workflow/sprints/2026-06-22-a/sprint-plan.yaml")
    plan = YAML.safe_load(File.read(plan_path), permitted_classes: [], aliases: false)
    plan["sprint_id"] = "different-sprint"
    File.write(plan_path, YAML.dump(plan))
    git(chain[:root], "add", plan_path)
    git(chain[:root], "commit", "-qm", "commit misplaced sprint plan")
    status = nil
    stdout, stderr = capture_io do
      status = Verdify::CLI.run(["route", "--repo", chain[:root], "--json"])
    end

    assert_equal 0, status, stderr
    assert_equal "SPRINT_PLAN_INVALID", JSON.parse(stdout)["current_state"]
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_route_requires_explicit_selection_for_concurrent_active_sprints
    chain = build_chain(route_ready: true)
    source = File.join(chain[:root], ".agent-workflow/sprints/2026-06-22-a/sprint-plan.yaml")
    destination = File.join(chain[:root], ".agent-workflow/sprints/2026-06-23-b/sprint-plan.yaml")
    FileUtils.mkdir_p(File.dirname(destination))
    second = YAML.safe_load(File.read(source), permitted_classes: [], aliases: false)
    second["sprint_id"] = "2026-06-23-b"
    File.write(destination, YAML.dump(second))
    git(chain[:root], "add", destination)
    git(chain[:root], "commit", "-qm", "add concurrent sprint")

    stdout, = capture_io { Verdify::CLI.run(["route", "--repo", chain[:root], "--json"]) }
    assert_equal "SPRINT_TRANSACTION_AMBIGUOUS", JSON.parse(stdout)["current_state"]

    selected_stdout, = capture_io do
      Verdify::CLI.run(["route", "--repo", chain[:root], "--sprint", "2026-06-22-a", "--json"])
    end
    refute_equal "SPRINT_TRANSACTION_AMBIGUOUS", JSON.parse(selected_stdout)["current_state"]

    unknown_stdout, = capture_io do
      Verdify::CLI.run(["route", "--repo", chain[:root], "--sprint", "missing-sprint", "--json"])
    end
    assert_equal "SPRINT_SELECTION_REQUIRED", JSON.parse(unknown_stdout)["current_state"]
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_route_accepts_approved_cancellation_terminalization
    chain = build_chain(route_ready: true)
    sprint_root = File.join(chain[:root], ".agent-workflow/sprints/2026-06-22-a")
    plan_path = File.join(sprint_root, "sprint-plan.yaml")
    plan = YAML.safe_load(File.read(plan_path), permitted_classes: [], aliases: false)
    plan["status"] = "cancelled"
    File.write(plan_path, YAML.dump(plan))
    File.write(File.join(sprint_root, "status.yaml"), YAML.dump(valid_sprint_status("2026-06-22-a", "CANCELLED")))
    gate_path = File.join(sprint_root, "gates/cancellation.yaml")
    FileUtils.mkdir_p(File.dirname(gate_path))
    File.write(gate_path, YAML.dump({
      "schema_ref" => "human-gate.schema.yaml",
      "kind" => "HumanGate",
      "schema_version" => "1.0",
      "gate_id" => "cancel-2026-06-22-a",
      "sprint_id" => "2026-06-22-a",
      "lane_id" => nil,
      "type" => "decision",
      "status" => "approved",
      "question" => "Cancel this sprint?",
      "owner" => "delivery-owner",
      "evidence_required" => ["Cancellation rationale"],
      "allowed_decisions" => ["cancel", "continue"],
      "decision" => "cancel",
      "rationale" => "Explicit cancellation test.",
      "opened_at" => "2026-07-09T00:00:00Z",
      "resolved_at" => "2026-07-09T00:01:00Z",
      "resume_state" => "CANCELLED"
    }))
    git(chain[:root], "add", plan_path, File.join(sprint_root, "status.yaml"), gate_path)
    git(chain[:root], "commit", "-qm", "approve sprint cancellation")
    stdout, = capture_io { Verdify::CLI.run(["route", "--repo", chain[:root], "--json"]) }

    decision = JSON.parse(stdout)
    assert_equal "STATE_OF_UNION_MISSING", decision["current_state"]
    assert_equal "state-of-union", decision["next_skill"]
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_route_ignores_multiple_verified_complete_sprints
    chain = build_chain(route_ready: true)
    first_sprint = "2026-06-22-a"
    second_sprint = "2026-06-23-b"
    write_completed_sprint(chain[:root], first_sprint)
    git(chain[:root], "add", ".agent-workflow/sprints/#{first_sprint}")
    git(chain[:root], "commit", "-qm", "complete first sprint")

    first_plan = File.join(chain[:root], ".agent-workflow/sprints/#{first_sprint}/sprint-plan.yaml")
    write_completed_sprint(chain[:root], second_sprint, plan_source: first_plan)
    git(chain[:root], "add", ".agent-workflow/sprints/#{second_sprint}")
    git(chain[:root], "commit", "-qm", "complete second sprint")

    stdout, = capture_io { Verdify::CLI.run(["route", "--repo", chain[:root], "--json"]) }
    decision = JSON.parse(stdout)

    assert_equal "STATE_OF_UNION_MISSING", decision["current_state"]
    assert_equal "state-of-union", decision["next_skill"]
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_route_accepts_strategy_only_merge_over_assessed_baseline
    chain = build_chain(route_ready: true)
    baseline = commit_cancelled_sprint(chain[:root])
    git(chain[:root], "checkout", "-qb", "strategy-update")
    write_approved_strategy(chain[:root], baseline)
    git(chain[:root], "add", ".agent-workflow/strategy")
    git(chain[:root], "commit", "-qm", "record approved strategy")
    git(chain[:root], "checkout", "-q", "main")
    git(chain[:root], "merge", "--no-ff", "-qm", "merge approved strategy", "strategy-update")

    stdout, = capture_io { Verdify::CLI.run(["route", "--repo", chain[:root], "--json"]) }
    decision = JSON.parse(stdout)

    assert_equal "REPO_HYGIENE_MISSING", decision["current_state"]
    assert_equal "repo-hygiene", decision["next_skill"]
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_route_rejects_material_change_after_strategy_baseline
    chain = build_chain(route_ready: true)
    baseline = commit_cancelled_sprint(chain[:root])
    write_approved_strategy(chain[:root], baseline)
    git(chain[:root], "add", ".agent-workflow/strategy")
    git(chain[:root], "commit", "-qm", "record approved strategy")
    File.open(File.join(chain[:root], "README.md"), "a") { |file| file << "material change\n" }
    git(chain[:root], "add", "README.md")
    git(chain[:root], "commit", "-qm", "change repository after assessment")

    stdout, = capture_io { Verdify::CLI.run(["route", "--repo", chain[:root], "--json"]) }
    decision = JSON.parse(stdout)

    assert_equal "STATE_OF_UNION_STALE", decision["current_state"]
    assert decision["evidence"].any? { |item| item["finding"].include?("README.md") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_route_rejects_nonexistent_strategy_baseline
    chain = build_chain(route_ready: true)
    commit_cancelled_sprint(chain[:root])
    write_approved_strategy(chain[:root], "0" * 40)
    git(chain[:root], "add", ".agent-workflow/strategy")
    git(chain[:root], "commit", "-qm", "record strategy with invalid baseline")

    stdout, = capture_io { Verdify::CLI.run(["route", "--repo", chain[:root], "--json"]) }
    decision = JSON.parse(stdout)

    assert_equal "STATE_OF_UNION_STALE", decision["current_state"]
    assert decision["evidence"].any? { |item| item["finding"].include?("full ancestor commit") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_route_rejects_committed_invalid_sprint_plan
    chain = build_chain(route_ready: true)
    plan_path = File.join(chain[:root], ".agent-workflow/sprints/2026-06-22-a/sprint-plan.yaml")
    plan = YAML.safe_load(File.read(plan_path), permitted_classes: [], aliases: false)
    plan.delete("goal")
    File.write(plan_path, YAML.dump(plan))
    git(chain[:root], "add", plan_path)
    git(chain[:root], "commit", "-qm", "commit invalid sprint plan")
    status = nil
    stdout, stderr = capture_io do
      status = Verdify::CLI.run(["route", "--repo", chain[:root], "--json"])
    end

    assert_equal 0, status, stderr
    assert_equal "SPRINT_PLAN_INVALID", JSON.parse(stdout)["current_state"]
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
  end

  def test_route_rejects_pushed_controller_commit_after_review_packet
    chain = build_chain(route_ready: true)
    prepare_controller_packet(chain)
    plan_path = File.join(chain[:root], ".agent-workflow/sprints/2026-06-22-a/sprint-plan.yaml")
    plan = YAML.safe_load(File.read(plan_path), permitted_classes: [], aliases: false)
    plan["goal"] = "Mutated after the review packet was assembled."
    File.write(plan_path, YAML.dump(plan))
    git(chain[:root], "add", plan_path)
    git(chain[:root], "commit", "-qm", "post-packet planning mutation")
    git(chain[:root], "push", "-q", "origin", "HEAD")
    status = nil
    stdout, stderr = capture_io do
      status = Verdify::CLI.run(["route", "--repo", chain[:root], "--json"])
    end

    assert_equal 0, status, stderr
    assert_equal "REVIEW_INBOX_INCOMPLETE", JSON.parse(stdout)["current_state"]
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
    FileUtils.rm_rf(chain[:remote_root]) if chain&.dig(:remote_root)
  end

  def test_route_rejects_unreviewed_controller_implementation_change
    chain = build_chain(route_ready: true)
    prepare_controller_packet(chain, extra_controller_path: true)
    status = nil
    stdout, stderr = capture_io do
      status = Verdify::CLI.run(["route", "--repo", chain[:root], "--json"])
    end

    assert_equal 0, status, stderr
    decision = JSON.parse(stdout)
    assert_equal "REVIEW_INBOX_INCOMPLETE", decision["current_state"]
    assert decision["evidence"].any? { |item| item["finding"].include?("controller-injection.txt") }
  ensure
    FileUtils.rm_rf(chain[:root]) if chain
    FileUtils.rm_rf(chain[:remote_root]) if chain&.dig(:remote_root)
  end

  private

  def default_gh_fixture(chain)
    pr_head = chain[:pr_head] || chain[:report_head]
    rest = {
      "head" => { "sha" => pr_head },
      "user" => { "id" => 1 },
      "merged" => false,
      "merge_commit_sha" => nil
    }
    {
      "branch_view" => { "number" => 456, "headRefOid" => pr_head },
      "pulls" => [Marshal.load(Marshal.dump(rest)), Marshal.load(Marshal.dump(rest))],
      "pr_view" => {
        "author" => { "login" => "worker" },
        "baseRefName" => chain[:integration_base] || "main",
        "headRefName" => chain[:lane_branch],
        "headRefOid" => pr_head,
        "isDraft" => false,
        "mergeStateStatus" => "CLEAN",
        "state" => "OPEN",
        "reviews" => [
          {
            "id" => "PRR_review_1",
            "state" => "APPROVED",
            "commit" => { "oid" => pr_head },
            "author" => { "login" => "human-reviewer" },
            "submittedAt" => "2026-07-09T00:07:00Z"
          }
        ],
        "statusCheckRollup" => [
          {
            "databaseId" => 100,
            "name" => "validate",
            "status" => "COMPLETED",
            "conclusion" => "SUCCESS",
            "workflowName" => "validate",
            "startedAt" => "2026-07-09T00:05:00Z",
            "completedAt" => "2026-07-09T00:06:00Z",
            "detailsUrl" => "https://github.com/example/test/actions/runs/100"
          }
        ]
      },
      "permission" => { "permission" => "admin", "user" => { "login" => "human-reviewer", "id" => 12_345 } }
    }
  end

  def with_fake_gh(chain, fixture = default_gh_fixture(chain))
    fake_root = Dir.mktmpdir("verdify-fake-gh-")
    fixture_path = File.join(fake_root, "fixture.json")
    counter_path = File.join(fake_root, "counter")
    executable = File.join(fake_root, "gh")
    File.write(fixture_path, JSON.pretty_generate(fixture))
    File.write(executable, <<~'RUBY')
      #!/usr/bin/env ruby
      require "json"
      fixture = JSON.parse(File.read(ENV.fetch("FAKE_GH_FIXTURE")))
      args = ARGV
      payload = case
                when args[0, 2] == ["pr", "view"] && args[2].to_s.match?(/\A\d+\z/)
                  fixture.fetch("pr_view")
                when args[0, 2] == ["pr", "view"]
                  fixture.fetch("branch_view")
                when args[0, 2] == ["api", "repos/example/test/pulls/456"]
                  counter_path = ENV.fetch("FAKE_GH_COUNTER")
                  index = File.file?(counter_path) ? File.read(counter_path).to_i : 0
                  File.write(counter_path, (index + 1).to_s)
                  fixture.fetch("pulls").fetch([index, fixture.fetch("pulls").length - 1].min)
                when args[0, 2] == ["api", "repos/example/test/collaborators/human-reviewer/permission"]
                  fixture.fetch("permission")
                else
                  warn "unexpected fake gh invocation: #{args.join(' ')}"
                  exit 64
                end
      puts JSON.generate(payload)
    RUBY
    FileUtils.chmod(0o755, executable)
    old_path = ENV["PATH"]
    old_fixture = ENV["FAKE_GH_FIXTURE"]
    old_counter = ENV["FAKE_GH_COUNTER"]
    ENV["PATH"] = "#{fake_root}#{File::PATH_SEPARATOR}#{old_path}"
    ENV["FAKE_GH_FIXTURE"] = fixture_path
    ENV["FAKE_GH_COUNTER"] = counter_path
    yield
  ensure
    ENV["PATH"] = old_path
    ENV["FAKE_GH_FIXTURE"] = old_fixture
    ENV["FAKE_GH_COUNTER"] = old_counter
    FileUtils.rm_rf(fake_root) if fake_root
  end

  def cleanup_chain(chain)
    return unless chain

    FileUtils.rm_rf(chain[:root])
    FileUtils.rm_rf(chain[:remote_container] || chain[:remote_root])
  end

  def valid_sprint_status(sprint_id, state)
    {
      "schema_ref" => "status.schema.yaml",
      "kind" => "SprintStatus",
      "schema_version" => "1.0",
      "sprint_id" => sprint_id,
      "state" => state,
      "updated_at" => "2026-07-09T00:10:00Z",
      "active_lanes" => [],
      "blockers" => [],
      "next_action" => "Follow the verified lifecycle route."
    }
  end

  def write_completed_sprint(root, sprint_id, plan_source: nil)
    sprint_root = File.join(root, ".agent-workflow/sprints", sprint_id)
    FileUtils.mkdir_p(File.join(sprint_root, "release"))
    FileUtils.mkdir_p(File.join(sprint_root, "outcome"))

    plan_path = File.join(sprint_root, "sprint-plan.yaml")
    source = plan_source || plan_path
    plan = YAML.safe_load(File.read(source), permitted_classes: [], aliases: false)
    plan["sprint_id"] = sprint_id
    plan["status"] = "complete"
    File.write(plan_path, YAML.dump(plan))

    File.write(File.join(sprint_root, "status.yaml"), YAML.dump(valid_sprint_status(sprint_id, "COMPLETE")))
    [
      "release/release-verification.yaml",
      "outcome/outcome-review.yaml"
    ].each do |relative|
      document = Verdify::SchemaValidator.load_document(
        Verdify::ROOT.join("examples/minimal-project/.agent-workflow/sprints/2026-06-22-a", relative)
      )
      document["sprint_id"] = sprint_id
      File.write(File.join(sprint_root, relative), YAML.dump(document))
    end
  end

  def commit_cancelled_sprint(root)
    sprint_root = File.join(root, ".agent-workflow/sprints/2026-06-22-a")
    plan_path = File.join(sprint_root, "sprint-plan.yaml")
    plan = YAML.safe_load(File.read(plan_path), permitted_classes: [], aliases: false)
    plan["status"] = "cancelled"
    File.write(plan_path, YAML.dump(plan))
    File.write(File.join(sprint_root, "status.yaml"), YAML.dump(valid_sprint_status("2026-06-22-a", "CANCELLED")))

    gate = valid_gate("cancel-2026-06-22-a", "2026-06-22-a", "approved")
    gate["question"] = "Cancel this sprint?"
    gate["allowed_decisions"] = ["cancel", "continue"]
    gate["decision"] = "cancel"
    gate["rationale"] = "Terminalize the fixture before strategy routing."
    gate["resolved_at"] = "2026-07-09T00:11:00Z"
    gate["resume_state"] = "CANCELLED"
    gate_path = File.join(sprint_root, "gates/cancellation.yaml")
    FileUtils.mkdir_p(File.dirname(gate_path))
    File.write(gate_path, YAML.dump(gate))

    git(root, "add", plan_path, File.join(sprint_root, "status.yaml"), gate_path)
    git(root, "commit", "-qm", "cancel fixture sprint")
    git(root, "rev-parse", "HEAD").strip
  end

  def write_approved_strategy(root, baseline)
    strategy_root = File.join(root, ".agent-workflow/strategy")
    FileUtils.mkdir_p(strategy_root)
    strategy = Verdify::SchemaValidator.load_document(
      Verdify::ROOT.join("examples/minimal-project/.agent-workflow/strategy/state-of-union.yaml")
    )
    strategy["baseline_sha"] = baseline
    File.write(File.join(strategy_root, "state-of-union.yaml"), YAML.dump(strategy))
  end

  def valid_gate(gate_id, sprint_id, status)
    {
      "schema_ref" => "human-gate.schema.yaml",
      "kind" => "HumanGate",
      "schema_version" => "1.0",
      "gate_id" => gate_id,
      "sprint_id" => sprint_id,
      "lane_id" => nil,
      "type" => "decision",
      "status" => status,
      "question" => "May routing continue?",
      "owner" => "delivery-owner",
      "evidence_required" => ["Decision rationale"],
      "allowed_decisions" => ["continue", "hold"],
      "decision" => nil,
      "rationale" => nil,
      "opened_at" => "2026-07-09T00:10:00Z",
      "resolved_at" => nil,
      "resume_state" => "IMPLEMENTING"
    }
  end

  def build_chain(critic_session_id: "critic-session", critic_agent: "critic-agent", critic_outcome: "approve", closeout_status: "ready_for_critic", extra_worker_evidence_path: false, extra_critic_evidence_path: false, worker_evidence_merge: false, closeout_sha256: nil, post_review_change: false, route_ready: false, lane_branch: "main", integration_base: "main", mutate_dispatch_during_implementation: false)
    root = Dir.mktmpdir("verdify-lane-review-")
    git(root, "init", "-q", "-b", "main")
    git(root, "config", "user.name", "Verdify Test")
    git(root, "config", "user.email", "verdify-test@example.invalid")
    example_root = Verdify::ROOT.join("examples/minimal-project/.agent-workflow")
    if route_ready
      workflow_root = File.join(root, ".agent-workflow")
      FileUtils.mkdir_p(workflow_root)
      %w[project architecture modules].each do |directory|
        FileUtils.cp_r(example_root.join(directory), File.join(workflow_root, directory))
      end
    end
    File.write(File.join(root, "README.md"), "# Test\n")
    git(root, "add", ".")
    git(root, "commit", "-qm", "foundation baseline")
    controller_baseline = git(root, "rev-parse", "HEAD").strip

    if route_ready
      FileUtils.mkdir_p(File.join(root, ".agent-workflow/sprints/2026-06-22-a"))
      plan_path = File.join(root, ".agent-workflow/sprints/2026-06-22-a/sprint-plan.yaml")
      FileUtils.cp(example_root.join("sprints/2026-06-22-a/sprint-plan.yaml"), plan_path)
      plan = YAML.safe_load(File.read(plan_path), permitted_classes: [], aliases: false)
      plan["baseline_sha"] = controller_baseline
      plan["lanes"].first["branch"] = lane_branch
      File.write(plan_path, YAML.dump(plan))
      release_plan_path = File.join(root, ".agent-workflow/sprints/2026-06-22-a/release/wave-release-plan.yaml")
      FileUtils.mkdir_p(File.dirname(release_plan_path))
      FileUtils.cp(example_root.join("sprints/2026-06-22-a/release/wave-release-plan.yaml"), release_plan_path)
      release_plan = YAML.safe_load(File.read(release_plan_path), permitted_classes: [], aliases: false)
      release_plan["github"]["repository"] = "example/test"
      release_plan["branch_model"]["base_ref"] = integration_base
      release_plan["github"]["required_checks"] = ["validate"]
      File.write(release_plan_path, YAML.dump(release_plan))
      git(root, "add", ".agent-workflow/sprints/2026-06-22-a")
      git(root, "commit", "-qm", "approve sprint and wave plan")
    end
    baseline = git(root, "rev-parse", "HEAD").strip

    sprint = ".agent-workflow/sprints/2026-06-22-a"
    contract_rel = "#{sprint}/lanes/contracts/issue-123-api.contract.yaml"
    closeout_rel = "#{sprint}/lanes/closeout/issue-123-api.closeout.yaml"
    critic_rel = "#{sprint}/critic/issue-123-api.critic.yaml"
    contract_path = File.join(root, contract_rel)
    closeout_path = File.join(root, closeout_rel)
    critic_path = File.join(root, critic_rel)
    [contract_path, closeout_path, critic_path].each { |path| FileUtils.mkdir_p(File.dirname(path)) }

    contract = Verdify::SchemaValidator.load_document(
      Verdify::ROOT.join("examples/minimal-project/.agent-workflow/sprints/2026-06-22-a/lanes/contracts/issue-123-api.contract.yaml")
    )
    contract["baseline_sha"] = baseline
    contract["branch"] = lane_branch
    contract["approval"] = { "status" => "approved", "approver" => "owner", "approved_at" => "2026-07-09T00:00:00Z" }
    File.write(contract_path, YAML.dump(contract))
    git(root, "add", contract_rel)
    git(root, "commit", "-qm", "approve lane contract")
    git(root, "checkout", "-qb", lane_branch) unless lane_branch == "main"
    File.open(contract_path, "a") { |file| file << "# unauthorized implementation-time policy mutation\n" } if mutate_dispatch_during_implementation
    File.write(File.join(root, "implementation.txt"), "implemented\n")
    implementation_paths = ["implementation.txt"]
    implementation_paths << contract_rel if mutate_dispatch_during_implementation
    git(root, "add", *implementation_paths)
    git(root, "commit", "-qm", "implementation")
    implementation = git(root, "rev-parse", "HEAD").strip

    closeout = {
      "schema_ref" => "lane-closeout.schema.yaml",
      "kind" => "LaneCloseout",
      "schema_version" => "2.0",
      "sprint_id" => "2026-06-22-a",
      "lane_id" => "issue-123-api",
      "status" => closeout_status,
      "issue_ids" => [123],
      "pull_request" => 456,
      "baseline_sha" => baseline,
      "implementation_head_sha" => implementation,
      "validated_head_sha" => implementation,
      "contract_hash" => Digest::SHA256.file(contract_path).hexdigest,
      "changed_paths" => ["implementation.txt"],
      "validation_results" => [
        { "id" => "test", "command" => "true", "exit_status" => 0, "result" => "passed", "executed_at" => "2026-07-09T00:01:00Z", "artifact" => nil }
      ],
      "acceptance_evidence" => [
        { "criterion_id" => "LANE-AC-01", "evidence_ids" => ["test"], "assessment" => "satisfied" }
      ],
      "discovered_issues" => [],
      "residual_risks" => [],
      "worktree_clean" => true,
      "worker_agent" => "worker-agent",
      "worker_session_id" => "worker-session",
      "completed_at" => "2026-07-09T00:02:00Z",
      "limitations" => []
    }
    git(root, "checkout", "-qb", "worker-evidence") if worker_evidence_merge
    File.write(closeout_path, YAML.dump(closeout))
    if extra_worker_evidence_path
      File.write(File.join(root, "unexpected.txt"), "substantive change\n")
      git(root, "add", "unexpected.txt")
    end
    git(root, "add", closeout_rel)
    git(root, "commit", "-qm", "worker evidence")
    if worker_evidence_merge
      git(root, "checkout", "-q", "main")
      git(root, "merge", "--no-ff", "-qm", "merge worker evidence", "worker-evidence")
    end
    evidence = git(root, "rev-parse", "HEAD").strip

    critic = {
      "schema_ref" => "critic-report.schema.yaml",
      "kind" => "CriticReport",
      "schema_version" => "2.0",
      "sprint_id" => "2026-06-22-a",
      "lane_id" => "issue-123-api",
      "pull_request" => 456,
      "worker_agent" => "worker-agent",
      "worker_session_id" => "worker-session",
      "critic_agent" => critic_agent,
      "implementation_head_sha" => implementation,
      "evidence_head_sha" => evidence,
      "reviewed_head_sha" => evidence,
      "closeout_path" => closeout_rel,
      "closeout_sha256" => closeout_sha256 || Digest::SHA256.file(closeout_path).hexdigest,
      "critic_session_id" => critic_session_id,
      "review_worktree" => root,
      "outcome" => critic_outcome,
      "findings" => [],
      "acceptance_assessment" => [
        { "criterion_id" => "LANE-AC-01", "assessment" => "satisfied", "evidence" => ["test"] }
      ],
      "evidence_assessment" => ["Implementation and evidence heads are distinct and traceable."],
      "integration_risks" => [],
      "residual_risks" => [],
      "reviewed_at" => "2026-07-09T00:03:00Z"
    }
    File.write(critic_path, YAML.dump(critic))
    if extra_critic_evidence_path
      File.write(File.join(root, "critic-unexpected.txt"), "substantive critic change\n")
      git(root, "add", "critic-unexpected.txt")
    end
    git(root, "add", critic_rel)
    git(root, "commit", "-qm", "critic evidence")
    report = git(root, "rev-parse", "HEAD").strip

    post_review_head = report
    if post_review_change
      File.write(File.join(root, "post-review.txt"), "stale approval\n")
      git(root, "add", "post-review.txt")
      git(root, "commit", "-qm", "post review change")
      post_review_head = git(root, "rev-parse", "HEAD").strip
    end

    {
      root: root,
      contract_path: contract_path,
      closeout_path: closeout_path,
      critic_path: critic_path,
      baseline: baseline,
      controller_baseline: controller_baseline,
      lane_branch: lane_branch,
      implementation_head: implementation,
      evidence_head: evidence,
      report_head: report,
      post_review_head: post_review_head,
      integration_base: integration_base
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

  def prepare_controller_packet(chain, extra_controller_path: false, github_remote: false, delete_local_lane: false)
    root = chain[:root]
    git(root, "checkout", "-qb", "controller/2026-06-22-a", chain[:controller_baseline])
    git(root, "checkout", chain[:lane_branch], "--", ".agent-workflow/sprints/2026-06-22-a")
    git(root, "commit", "-qm", "copy approved lane evidence")
    if extra_controller_path
      File.write(File.join(root, "controller-injection.txt"), "unreviewed controller change\n")
      git(root, "add", "controller-injection.txt")
      git(root, "commit", "-qm", "inject unreviewed controller change")
    end
    packet_rel = ".agent-workflow/sprints/2026-06-22-a/review/review-inbox-packet.yaml"
    packet_path = File.join(root, packet_rel)
    FileUtils.mkdir_p(File.dirname(packet_path))
    packet = Verdify::SchemaValidator.load_document(
      Verdify::ROOT.join("examples/minimal-project/.agent-workflow/sprints/2026-06-22-a/review/review-inbox-packet.yaml")
    )
    packet["traceability"]["repository"] = "example/test"
    packet["traceability"]["base_ref"] = chain[:integration_base] || "main"
    submission = packet["traceability"]["review_submissions"].first
    submission["pull_request"] = 456
    submission["review_submission_head_sha"] = chain[:report_head]
    packet["pull_requests"].first["identifier"] = "#456"
    packet["pull_requests"].first["url"] = "https://github.com/example/test/pull/456"
    File.write(packet_path, YAML.dump(packet))
    git(root, "add", packet_rel)
    git(root, "commit", "-qm", "assemble controller review packet")

    remote_container = github_remote ? Dir.mktmpdir("verdify-github-remote-") : nil
    remote_root = github_remote ? File.join(remote_container, "github.com/example/test.git") : "#{root}-origin.git"
    FileUtils.mkdir_p(File.dirname(remote_root))
    _stdout, stderr, status = Open3.capture3("git", "init", "--bare", "-q", remote_root)
    raise "git init --bare failed: #{stderr}" unless status.success?

    git(root, "remote", "add", "origin", remote_root)
    git(root, "push", "-q", "origin", "main")
    if chain[:lane_branch] != "main"
      git(root, "push", "-q", "origin", chain[:lane_branch])
      git(root, "push", "-q", "origin", "#{chain[:pr_head] || chain[:report_head]}:refs/pull/456/head")
    end
    git(root, "push", "-qu", "origin", "HEAD")
    git(root, "branch", "-D", chain[:lane_branch]) if delete_local_lane && chain[:lane_branch] != "main"
    chain[:remote_root] = remote_root
    chain[:remote_container] = remote_container
  end

  def git(root, *args)
    stdout, stderr, status = Open3.capture3("git", "-C", root, *args)
    raise "git #{args.join(' ')} failed: #{stderr}" unless status.success?

    stdout
  end
end
