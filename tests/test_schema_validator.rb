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
    root = Verdify::ROOT.join("examples/minimal-project/.verdify")
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
end
