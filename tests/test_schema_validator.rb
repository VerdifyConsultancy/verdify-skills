#!/usr/bin/env ruby
# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/verdify"

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
end
