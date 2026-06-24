# frozen_string_literal: true

require "json"
require "minitest/autorun"

class LaneDeliveryCorrectnessTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_closeout_instruction_uses_schema_grounded_status
    skill = File.read(File.join(ROOT, "skills/lane-delivery/SKILL.md"))

    assert_includes skill, "Write the closeout file with `status: ready_for_critic`"
    assert_includes skill, "closeout-file presence with no critic file"
    refute_includes skill, "Set the lane to `READY_FOR_CRITIC`"
    refute_includes skill, "do not mark it integrated or complete"
  end

  def test_fix_forward_names_single_sequential_lease_procedure
    skill = File.read(File.join(ROOT, "skills/lane-delivery/SKILL.md"))

    assert_includes skill, "one canonical worktree/lease procedure"
    assert_includes skill, "bin/verdify lane release --keep-worktree"
    assert_includes skill, "new `--session-id`"
    assert_includes skill, "no other active worker lease owns the lane/worktree"
  end

  def test_lane_delivery_closeout_eval_references_actual_status_enum
    evals = JSON.parse(File.read(File.join(ROOT, "evaluations/lane-delivery/evals.json")))
    closeout = evals.fetch("evals").find { |item| item.fetch("id") == "evidence-backed-closeout" }
    expected_output = closeout.fetch("expected_output")

    refute_includes expected_output, "complete-with-risks"
    assert_includes expected_output, "ready_for_critic"
    assert_includes expected_output, "blocked"
    assert_includes expected_output, "failed"
    assert_includes expected_output, "decision_required"
  end
end
