#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "open3"
require "pathname"
require "rbconfig"
require "tmpdir"
require "yaml"

require_relative "../lib/verdify"

class LaneQrSchemarefsTest < Minitest::Test
  ROOT = Verdify::ROOT

  def test_question_resolution_artifacts_use_real_schema_refs_and_validate
    Dir.mktmpdir("verdify-qr-schemarefs") do |dir|
      workspace = Pathname.new(dir)
      corpus = workspace.join("corpus")
      FileUtils.mkdir_p(corpus.join("00-product"))
      corpus.join("00-product/questions.md").write(<<~MARKDOWN)
        # Product questions

        [QUESTION:NSQ-001] What schema validates question-resolution artifacts?
      MARKDOWN

      inventory = workspace.join("inventory.yaml")
      cluster_map = workspace.join("cluster-map.yaml")

      run!(RbConfig.ruby, "skills/northstar-question-resolution/scripts/question_inventory.rb",
           "--root", corpus.to_s, "--output", inventory.to_s)
      inventory_doc = YAML.safe_load(inventory.read, permitted_classes: [], aliases: false)
      assert_equal "northstar-question-inventory.schema.yaml", inventory_doc["schema_ref"]
      assert_equal "NorthStarQuestionInventory", inventory_doc["kind"]
      assert_includes run!(RbConfig.ruby, "bin/verdify", "artifact", "validate", "--file", inventory.to_s), "valid"

      run!(RbConfig.ruby, "skills/northstar-question-resolution/scripts/cluster_questions.rb",
           "--inventory", inventory.to_s, "--output", cluster_map.to_s,
           "--run-id", "test-run", "--target-repository", "OWNER/REPO")
      cluster_doc = YAML.safe_load(cluster_map.read, permitted_classes: [], aliases: false)
      assert_equal "northstar-question-cluster-map.schema.yaml", cluster_doc["schema_ref"]
      assert_equal "NorthStarQuestionClusterMap", cluster_doc["kind"]
      assert_includes run!(RbConfig.ruby, "bin/verdify", "artifact", "validate", "--file", cluster_map.to_s), "valid"
    end

    template = ROOT.join("skills/northstar-question-resolution/assets/resolution-register.template.yaml")
    template_doc = YAML.safe_load(template.read, permitted_classes: [], aliases: false)
    assert_equal "northstar-question-resolution-register.schema.yaml", template_doc["schema_ref"]
    assert_equal "NorthStarQuestionResolutionRegister", template_doc["kind"]
    assert_includes run!(RbConfig.ruby, "bin/verdify", "artifact", "validate", "--file", template.to_s), "valid"
  end

  def test_question_resolution_schemas_close_top_level_properties
    {
      "northstar-question-inventory.schema.yaml" => "NorthStarQuestionInventory",
      "northstar-question-cluster-map.schema.yaml" => "NorthStarQuestionClusterMap",
      "northstar-question-resolution-register.schema.yaml" => "NorthStarQuestionResolutionRegister"
    }.each do |schema_name, kind|
      schema = YAML.safe_load(ROOT.join("schemas", schema_name).read, permitted_classes: [], aliases: false)
      assert_equal false, schema["additionalProperties"], schema_name
      assert_includes schema["required"], "schema_ref"
      assert_includes schema["required"], "kind"
      assert_equal schema_name, schema.dig("properties", "schema_ref", "const")
      assert_equal kind, schema.dig("properties", "kind", "const")
    end
  end

  private

  def run!(*command)
    stdout, stderr, status = Open3.capture3(*command, chdir: ROOT.to_s)
    assert status.success?, "#{command.join(' ')} failed\nstdout:\n#{stdout}\nstderr:\n#{stderr}"
    stdout
  end
end
