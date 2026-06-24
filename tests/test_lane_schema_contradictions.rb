#!/usr/bin/env ruby
# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/verdify"

class LaneSchemaContradictionsTest < Minitest::Test
  def load_yaml(relative_path)
    Verdify::SchemaValidator.load_document(Verdify::ROOT.join(relative_path))
  end

  def test_northstar_planning_contract_uses_schema_disposition_enum
    schema = load_yaml("schemas/northstar-plan.schema.yaml")
    enum = schema.dig("properties", "adversarial_findings", "items", "properties", "disposition", "enum")
    contract = Verdify::ROOT.join("skills/northstar-planning/references/planning-contract.md").read

    enum.each do |value|
      assert_includes contract, "`#{value}`"
    end
    refute_includes contract, "final_lock_required"
  end

  def test_transcript_replan_allows_documented_affected_skill_or_lane
    schema = load_yaml("schemas/transcript-replan.schema.yaml")
    document = {
      "schema_ref" => "transcript-replan.schema.yaml",
      "kind" => "TranscriptReplan",
      "schema_version" => "1.0",
      "source_id" => "walk-2026-06-24",
      "status" => "draft",
      "generated_at" => "2026-06-24T00:00:00Z",
      "repositories" => ["verdify-skills"],
      "items" => [
        {
          "id" => "TR-001",
          "category" => "requirement",
          "statement" => "Route schema contradictions to the owning lane.",
          "evidence_status" => "reported",
          "target_repository" => "verdify-skills",
          "lifecycle_phase" => "lane-delivery",
          "affected_skill_or_lane" => "lane-schema-contradictions",
          "next_action" => "Implement the contract-scoped fix.",
          "protected_artifact_impact" => "none"
        }
      ],
      "conflicts" => [],
      "proposed_artifact_changes" => [],
      "issue_recommendations" => [],
      "gate_recommendations" => [],
      "handoff" => {
        "next_skill" => "lane-delivery",
        "next_mode" => "implementation",
        "reason" => "Lane contract is approved."
      },
      "approval" => {
        "status" => "pending",
        "approver" => nil,
        "approved_at" => nil
      }
    }

    assert_empty Verdify::SchemaValidator.new.validate(document, schema)
  end

  def test_critic_report_template_is_schema_valid_with_empty_acceptance_assessment
    template_path = Verdify::ROOT.join("skills/independent-critic/assets/critic-report.template.yaml")
    schema_path = Verdify::ROOT.join("schemas/critic-report.schema.yaml")
    template = Verdify::SchemaValidator.load_document(template_path)

    assert_equal [], template["acceptance_assessment"]
    template_errors = Verdify::SchemaValidator.validate_file(template_path, schema_path)
    template_errors.concat(Verdify::SemanticValidator.validate(template))
    assert_empty template_errors
  end

  def test_project_definition_skill_lists_all_schema_id_prefixes
    schema = load_yaml("schemas/project-definition.schema.yaml")
    skill = Verdify::ROOT.join("skills/project-definition/SKILL.md").read
    prefixes = id_prefixes(schema).sort

    prefixes.each do |prefix|
      assert_includes skill, "`#{prefix}-001`"
    end
  end

  private

  def id_prefixes(node, prefixes = [])
    case node
    when Hash
      if node["pattern"].is_a?(String)
        match = node["pattern"].match(/\A\^([A-Z]+)-\[0-9\]\{3,\}\$\z/)
        prefixes << match[1] if match
      end
      node.each_value { |child| id_prefixes(child, prefixes) }
    when Array
      node.each { |child| id_prefixes(child, prefixes) }
    end
    prefixes.uniq
  end
end
