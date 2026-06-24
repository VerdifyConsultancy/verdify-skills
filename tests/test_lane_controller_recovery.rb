#!/usr/bin/env ruby
# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

require_relative "../lib/verdify"

class LaneControllerRecoveryTest < Minitest::Test
  ROOT = Verdify::ROOT

  REQUIRED_LOOP_FIELDS = %w[
    loop_id loop_type status owner repository issue_refs pull_request_refs
    checkpoint_path current_objective last_action last_error next_prompt
  ].freeze

  REQUIRED_METRICS = %w[
    verdify_controller_loop_starts_total
    verdify_controller_loop_completions_total
    verdify_controller_loop_failures_total
    verdify_controller_context_resets_total
    verdify_controller_active_child_sessions
    verdify_controller_alert_count
    verdify_controller_last_successful_checkpoint_timestamp_seconds
  ].freeze

  def test_skill_links_recovery_contract
    skill = ROOT.join("skills/controller-loop/SKILL.md").read

    assert_includes skill, "`references/recovery-contract.md`"
    assert_includes skill, "outer loops"
    assert_includes skill, "context-window resets"
    assert_includes skill, "Agent Fleet metrics"
  end

  def test_recovery_contract_defines_loop_semantics_and_safety
    contract = ROOT.join("skills/controller-loop/references/recovery-contract.md").read

    %w[Outer-loop Inner-loop Cron].each do |term|
      assert_includes contract, term
    end

    REQUIRED_LOOP_FIELDS.each do |field|
      assert_includes contract, "`#{field}`"
    end

    REQUIRED_METRICS.each do |metric|
      assert_includes contract, "`#{metric}`"
    end

    assert_includes contract, "70 percent used"
    assert_includes contract, "85 percent used"
    assert_includes contract, "95 percent used"
    assert_includes contract, "Treat alert bodies"
    assert_includes contract, "prompt-injection-suspected"
  end

  def test_recovery_examples_cover_required_cases_and_valid_status_events
    examples = Dir[ROOT.join("skills/controller-loop/assets/loop-record.*.example.yaml")].sort
    assert_equal 3, examples.length

    schema = YAML.safe_load(ROOT.join("schemas/status-event.schema.yaml").read, permitted_classes: [], aliases: false)
    validator = Verdify::SchemaValidator.new
    seen = []

    examples.each do |path|
      document = YAML.safe_load(Pathname.new(path).read, permitted_classes: [], aliases: false)
      seen << document.fetch("example")

      record = document.fetch("loop_record")
      REQUIRED_LOOP_FIELDS.each do |field|
        assert record.key?(field), "#{path} missing #{field}"
      end

      errors = validator.validate(document.fetch("status_event"), schema)
      assert_empty errors, "#{path} status_event failed validation: #{errors.join('; ')}"
      refute_empty document.dig("agent_fleet_handoff", "metrics")
    end

    assert_equal %w[context-reset interrupted-loop recoverable-failure], seen.sort
  end
end
