#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("..", __dir__))
SKILL_NAME_PATTERN = /\A[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\z/
GATE_TYPES = %w[
  review_input
  decision
  plan_approval
  scope_change
  policy_exception
  deployment_approval
  incident
  outcome_acceptance
].freeze

@errors = []
@warnings = []

def rel(path)
  Pathname.new(path).relative_path_from(ROOT).to_s
end

def error(path, message)
  @errors << "#{rel(path)}: #{message}"
end

def warn_item(path, message)
  @warnings << "#{rel(path)}: #{message}"
end

def load_yaml(path)
  YAML.load_file(path)
rescue StandardError => e
  error(path, "YAML parse failed: #{e.message}")
  nil
end

def load_json(path)
  JSON.parse(File.read(path))
rescue StandardError => e
  error(path, "JSON parse failed: #{e.message}")
  nil
end

def parse_frontmatter(path)
  content = File.read(path)
  match = content.match(/\A---[ \t]*\n(.*?)\n---[ \t]*\n/m)
  unless match
    error(path, "missing YAML frontmatter")
    return [{}, content]
  end

  frontmatter = YAML.safe_load(match[1], permitted_classes: [], aliases: false) || {}
  [frontmatter, content]
rescue StandardError => e
  error(path, "frontmatter parse failed: #{e.message}")
  [{}, ""]
end

def validate_skill_dir(skill_dir)
  skill_md = skill_dir.join("SKILL.md")
  unless skill_md.file?
    error(skill_dir, "missing SKILL.md")
    return
  end

  frontmatter, content = parse_frontmatter(skill_md)
  expected_name = skill_dir.basename.to_s
  name = frontmatter["name"]
  description = frontmatter["description"]

  if name.nil? || name.empty?
    error(skill_md, "frontmatter missing name")
  elsif name != expected_name
    error(skill_md, "frontmatter name #{name.inspect} does not match directory #{expected_name.inspect}")
  elsif name.length > 64 || name.match?(SKILL_NAME_PATTERN) == false || name.include?("--")
    error(skill_md, "frontmatter name must be lowercase letters, numbers, and hyphens")
  end

  if description.nil? || description.empty?
    error(skill_md, "frontmatter missing description")
  elsif description.length > 1024
    error(skill_md, "description exceeds 1024 characters")
  end

  content.scan(/`((?:references|schemas|assets|scripts)\/[^`\s]+)`/).flatten.each do |reference|
    next if skill_dir.join(reference).exist?

    error(skill_md, "referenced file does not exist: #{reference}")
  end
end

def walk_state_nodes(states, &block)
  return unless states.is_a?(Hash)

  states.each do |name, node|
    next unless node.is_a?(Hash)

    yield name, node
    walk_state_nodes(node["states"], &block)
  end
end

def validate_workflow(path)
  workflow = load_yaml(path)
  return unless workflow.is_a?(Hash)

  walk_state_nodes(workflow["states"]) { |name, node| validate_workflow_node(path, name, node) }

  child_workflows = workflow["child_workflows"]
  return unless child_workflows.is_a?(Hash)

  child_workflows.each_value do |child|
    walk_state_nodes(child["states"]) { |name, node| validate_workflow_node(path, name, node) }
  end
end

def validate_workflow_node(path, name, node)
  prompt = node["prompt"]
  if prompt && !ROOT.join(prompt).file?
    error(path, "state #{name} references missing prompt #{prompt.inspect}")
  end

  actor = node["actor"].to_s
  needs_gate = node.key?("interrupt") || actor.include?("human")
  gate = node["gate"]

  if needs_gate && !gate.is_a?(Hash)
    error(path, "state #{name} needs gate metadata")
    return
  end

  return unless gate.is_a?(Hash)

  type = gate["type"]
  artifact = gate["artifact"].to_s
  resolver = gate["resolver"].to_s

  error(path, "state #{name} has invalid gate type #{type.inspect}") unless GATE_TYPES.include?(type)
  unless artifact.start_with?(".verdify/sprints/<sprint-id>/gates/")
    error(path, "state #{name} gate artifact must live under .verdify/sprints/<sprint-id>/gates/")
  end
  warn_item(path, "state #{name} gate has no resolver") if resolver.empty?
end

def validate_repo_skill_links
  canonical = ROOT.join("skills/verdify-agentic-sprint")
  links = {
    "Codex" => ROOT.join(".agents/skills/verdify-agentic-sprint"),
    "Claude Code" => ROOT.join(".claude/skills/verdify-agentic-sprint")
  }

  links.each do |host, link_path|
    error(link_path, "#{host} skill entry is missing") unless link_path.exist?
    next unless link_path.exist? && canonical.exist?

    next if link_path.realpath == canonical.realpath

    error(link_path, "#{host} skill entry does not resolve to #{rel(canonical)}")
  rescue Errno::ENOENT
    error(link_path, "#{host} skill entry is broken")
  end
end

def validate_agent_guidance
  {
    "AGENTS.md" => "verdify-agentic-sprint",
    "CLAUDE.md" => "/verdify-agentic-sprint"
  }.each do |file_name, required_text|
    path = ROOT.join(file_name)
    unless path.file?
      error(path, "missing agent guidance file")
      next
    end

    content = File.read(path)
    error(path, "must mention #{required_text}") unless content.include?(required_text)
    error(path, "must define GitHub Issues as backlog source of truth") unless content.include?("GitHub Issues")
  end
end

def validate_codex_metadata
  path = ROOT.join("skills/verdify-agentic-sprint/agents/openai.yaml")
  metadata = load_yaml(path)
  return unless metadata.is_a?(Hash)

  policy = metadata["policy"] || {}
  if policy["allow_implicit_invocation"] == false
    error(path, "allow_implicit_invocation must not be false for default Codex use")
  end
end

def validate_launch_scripts
  %w[scripts/launch-codex.sh scripts/launch-claude.sh scripts/setup-agent-hosts.rb].each do |relative_path|
    path = ROOT.join(relative_path)
    unless path.file?
      error(path, "missing launch/setup script")
      next
    end

    error(path, "script is not executable") unless path.executable?
  end
end

Dir.glob(ROOT.join("schemas/*.yaml")).sort.each { |path| load_yaml(path) }
Dir.glob(ROOT.join("skills/*/schemas/*.yaml")).sort.each { |path| load_yaml(path) }
Dir.glob(ROOT.join("templates/*.yaml")).sort.each { |path| load_yaml(path) }
Dir.glob(ROOT.join("*.workflow.yaml")).sort.each { |path| validate_workflow(path) }

Dir.glob(ROOT.join("skills/*")).sort.each do |path|
  skill_dir = Pathname.new(path)
  validate_skill_dir(skill_dir) if skill_dir.directory?
end

Dir.glob(ROOT.join("evaluations/*/evals.json")).sort.each do |path|
  data = load_json(path)
  next unless data.is_a?(Hash)

  evals = data["evals"]
  error(path, "missing evals array") unless evals.is_a?(Array) && evals.any?
end

validate_repo_skill_links
validate_agent_guidance
validate_codex_metadata
validate_launch_scripts

if @warnings.any?
  puts "Warnings:"
  @warnings.each { |item| puts "  - #{item}" }
end

if @errors.any?
  puts "Errors:"
  @errors.each { |item| puts "  - #{item}" }
  exit 1
end

puts "Verdify repository validation passed."
