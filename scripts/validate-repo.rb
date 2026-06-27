#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"
require "pathname"
require "yaml"
require_relative "../lib/verdify"

ROOT = Pathname.new(File.expand_path("..", __dir__))
SKILL_NAME_PATTERN = /\A[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\z/
SKILL_REFERENCE_PATTERN = /\A(?:
  (?:references|assets|scripts)\/[^`\s]+|
  \.\.\/[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\/(?:references|assets|scripts)\/[^`\s]+|
  skills\/[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\/(?:references|assets|scripts)\/[^`\s]+|
  \.\.\/\.\.\/(?:schemas|bin)\/[^`\s]+
)\z/x
SUPPORTED_SCHEMA_KEYWORDS = %w[
  $schema $id $defs $ref title description type const enum required properties
  additionalProperties items prefixItems minItems maxItems uniqueItems pattern
  patternProperties dependentRequired minLength maxLength minimum maximum allOf
  anyOf oneOf format if then else
].freeze
REQUIRED_SKILLS = %w[
  project-router repo-bootstrap transcript-replan northstar-research-ingest northstar-planning northstar-interview
  northstar-question-resolution project-definition architecture-contracts state-of-union repo-hygiene sprint-planning
  sprint-orchestrator controller-loop subagent-worktree platform-readiness gravity-readiness lane-delivery
  independent-critic release-verification consensus-audit-workflow issue-triage
].freeze
STANDALONE_SKILLS = %w[issue-triage].freeze
STANDARD_LIFECYCLE_STATES = %w[
  NOT_STARTED ORIENTING DEFINING ARCHITECTING PLANNING AWAITING_APPROVAL READY IMPLEMENTING
  VALIDATING BLOCKED DECISION_REQUIRED READY_FOR_CRITIC CHANGES_REQUESTED READY_FOR_INTEGRATION
  INTEGRATING READY_FOR_DEPLOYMENT DEPLOYING VERIFYING_DEPLOYMENT AWAITING_OUTCOME_ACCEPTANCE
  COMPLETE FAILED CANCELLED
].freeze
REQUIRED_PR_SECTIONS = [
  "Backlog issue", "Lane contract", "Outcome", "Scope proof", "Evidence", "Risk and deployment impact"
].freeze

class RepoValidator
  attr_reader :errors, :warnings

  def initialize
    @errors = []
    @warnings = []
    @schema_ids = {}
  end

  def run
    validate_required_files
    validate_parseable_files
    validate_schemas
    validate_lifecycle_config
    validate_skills
    validate_host_links
    validate_workflow
    validate_cli_lifecycle_alignment
    validate_github_templates
    validate_evaluations
    validate_scripts
    validate_examples
    validate_no_canonical_duplicates
    report
  end

  private

  def rel(path)
    Pathname.new(path).expand_path.relative_path_from(ROOT).to_s
  rescue ArgumentError
    path.to_s
  end

  def error(path, message)
    @errors << "#{rel(path)}: #{message}"
  end

  def warning(path, message)
    @warnings << "#{rel(path)}: #{message}"
  end

  def load_yaml(path)
    YAML.safe_load(Pathname.new(path).read, permitted_classes: [], aliases: false)
  rescue Psych::Exception => e
    error(path, "YAML parse failed: #{e.message}")
    nil
  end

  def load_json(path)
    JSON.parse(Pathname.new(path).read)
  rescue JSON::ParserError => e
    error(path, "JSON parse failed: #{e.message}")
    nil
  end

  def lifecycle_config
    @lifecycle_config ||= begin
      config = load_yaml(ROOT.join("config/lifecycle.yaml"))
      config.is_a?(Hash) ? config : {}
    end
  end

  def canonical_lifecycle_skills
    @canonical_lifecycle_skills ||= Array(lifecycle_config["skills"]).map { |entry| entry["name"].to_s }
  end

  def standalone_skill_names
    @standalone_skill_names ||= Array(lifecycle_config["standalone_skills"]).map { |entry| entry["name"].to_s }
  end

  def lifecycle_modes
    @lifecycle_modes ||= Array(lifecycle_config["skills"]).each_with_object({}) do |entry, modes|
      modes[entry["name"].to_s] = Array(entry["modes"]).map(&:to_s)
    end
  end

  def validate_mode_membership(path, skill, mode, context)
    skill = skill.to_s
    mode = mode.to_s
    modes = lifecycle_modes[skill]
    if modes.nil?
      error(path, "#{context} references non-lifecycle skill #{skill}")
    elsif mode.empty?
      error(path, "#{context} has no mode")
    elsif !modes.include?(mode)
      error(path, "#{context} mode #{mode.inspect} is not declared for #{skill} in config/lifecycle.yaml")
    end
  end

  def validate_required_files
    %w[
      README.md COMMON_OPERATING_CONTRACT.md AGENTS.md CLAUDE.md WORKFLOW.md AUTOMATION.md
      CONTRIBUTING.md SECURITY.md CHANGELOG.md VERSION Makefile verdify.workflow.yaml
      package.json npm/bin/verdify.js
      config/authority-matrix.yaml config/github-primitives.yaml config/lifecycle.yaml
      bin/verdify scripts/validate-repo.rb scripts/setup-agent-hosts.rb scripts/pr-policy.rb scripts/release-preflight.rb
      scripts/bootstrap-agent-session.sh scripts/verify-package.sh .github/pull_request_template.md
      .github/ISSUE_TEMPLATE/problem.yml .github/ISSUE_TEMPLATE/decision.yml
      .github/workflows/validate.yml .github/workflows/policy.yml .github/workflows/release-pr.yml
      .github/workflows/publish-npm.yml
    ].each do |relative|
      path = ROOT.join(relative)
      error(path, "required file is missing") unless path.file?
    end
  end

  def validate_parseable_files
    Dir[ROOT.join("{config,schemas,.github,skills,examples}/**/*.{yaml,yml}")].sort.each { |p| load_yaml(p) }
    Dir[ROOT.join("{evaluations,examples}/**/*.json")].sort.each { |p| load_json(p) }
  end

  def validate_schemas
    paths = Dir[ROOT.join("schemas/*.schema.yaml")].sort.map { |p| Pathname.new(p) }
    error(ROOT.join("schemas"), "expected canonical schemas") if paths.empty?
    paths.each do |path|
      schema = load_yaml(path)
      next unless schema.is_a?(Hash)

      error(path, "must declare JSON Schema draft 2020-12") unless schema["$schema"] == "https://json-schema.org/draft/2020-12/schema"
      id = schema["$id"].to_s
      error(path, "missing $id") if id.empty?
      if !id.empty? && @schema_ids.key?(id)
        error(path, "duplicates $id from #{rel(@schema_ids[id])}")
      else
        @schema_ids[id] = path unless id.empty?
      end
      error(path, "top-level schema must be an object") unless schema["type"] == "object"
      error(path, "top-level schema must close unknown properties") unless schema["additionalProperties"] == false
      error(path, "schema_ref const should equal filename") unless schema.dig("properties", "schema_ref", "const") == path.basename.to_s
      validate_schema_keyword_support(path, schema)
      validate_route_decision_skill_enum(path, schema) if path.basename.to_s == "route-decision.schema.yaml"
    end
  end

  def validate_lifecycle_config
    path = ROOT.join("config/lifecycle.yaml")
    config = lifecycle_config
    return if config.empty?

    unless config["canonical_source"] == "config/lifecycle.yaml"
      error(path, "canonical_source must name config/lifecycle.yaml")
    end

    unless Array(config["standard_states"]) == STANDARD_LIFECYCLE_STATES
      error(path, "standard_states must match COMMON_OPERATING_CONTRACT.md lifecycle states")
    end

    skills = Array(config["skills"])
    names = skills.map { |entry| entry["name"].to_s }
    lifecycle_required = REQUIRED_SKILLS - STANDALONE_SKILLS
    missing = lifecycle_required - names
    extra = names - lifecycle_required
    error(path, "skills missing lifecycle skills: #{missing.join(', ')}") unless missing.empty?
    error(path, "skills contains non-lifecycle skills: #{extra.join(', ')}") unless extra.empty?
    error(path, "skills must not contain duplicates") unless names.uniq.length == names.length

    orders = skills.map { |entry| entry["order"] }
    unless orders == (1..skills.length).to_a
      error(path, "skills order must be contiguous 1..#{skills.length} in canonical lifecycle order")
    end
    skills.each do |entry|
      modes = Array(entry["modes"]).map(&:to_s)
      error(path, "#{entry['name']} must declare at least one mode") if modes.empty?
      error(path, "#{entry['name']} modes must be unique") unless modes.uniq.length == modes.length
    end

    expected_cycle = names + ["project-router"]
    error(path, "default_cycle must follow canonical skill order and return to project-router") unless Array(config["default_cycle"]) == expected_cycle

    standalone = Array(config["standalone_skills"])
    standalone_names = standalone.map { |entry| entry["name"].to_s }
    error(path, "standalone_skills must be exactly: #{STANDALONE_SKILLS.join(', ')}") unless standalone_names == STANDALONE_SKILLS
    standalone.each do |entry|
      error(path, "#{entry['name']} standalone entry must have category standalone") unless entry["category"] == "standalone"
      error(path, "#{entry['name']} standalone entry must not declare lifecycle order") if entry.key?("order")
    end
  end

  def parse_frontmatter(path)
    content = File.binread(path).force_encoding(Encoding::UTF_8)
    unless content.valid_encoding?
      error(path, "is not valid UTF-8")
      return [{}, ""]
    end
    match = content.match(/\A---[ \t]*\n(.*?)\n---[ \t]*\n/m)
    unless match
      error(path, "missing YAML frontmatter")
      return [{}, content]
    end
    [YAML.safe_load(match[1], permitted_classes: [], aliases: false) || {}, content]
  rescue Psych::Exception => e
    error(path, "frontmatter parse failed: #{e.message}")
    [{}, ""]
  end

  def validate_skills
    actual = Dir[ROOT.join("skills/*/SKILL.md")].sort.map { |p| Pathname.new(p).dirname.basename.to_s }
    missing = REQUIRED_SKILLS - actual
    extra = actual - REQUIRED_SKILLS
    error(ROOT.join("skills"), "missing skills: #{missing.join(', ')}") unless missing.empty?
    error(ROOT.join("skills"), "unexpected top-level skills: #{extra.join(', ')}") unless extra.empty?

    REQUIRED_SKILLS.each do |name|
      dir = ROOT.join("skills", name)
      skill = dir.join("SKILL.md")
      next unless skill.file?
      frontmatter, content = parse_frontmatter(skill)
      fm_name = frontmatter["name"].to_s
      description = frontmatter["description"].to_s
      lifecycle_order = frontmatter.dig("metadata", "lifecycle-order")
      error(skill, "name must match directory") unless fm_name == name
      error(skill, "invalid skill name") unless fm_name.match?(SKILL_NAME_PATTERN) && !fm_name.include?("--") && fm_name.length <= 64
      error(skill, "description is required") if description.empty?
      error(skill, "description exceeds 1024 characters") if description.length > 1024
      error(skill, "description should state when the skill applies") unless description.match?(/\bUse\b/i)
      error(skill, "SKILL.md exceeds the progressive-disclosure limit of 500 lines") if content.lines.length > 500
      error(skill, "metadata.version must match VERSION") unless frontmatter.dig("metadata", "version").to_s == Verdify::VERSION
      error(skill, "metadata.lifecycle-order must be omitted; config/lifecycle.yaml is canonical") unless lifecycle_order.nil?
      if STANDALONE_SKILLS.include?(name)
        error(skill, "standalone skill must declare metadata.category: standalone") unless frontmatter.dig("metadata", "category") == "standalone"
      else
        error(skill, "lifecycle skill must not declare standalone category") if frontmatter.dig("metadata", "category") == "standalone"
        error(skill, "lifecycle skill missing from config/lifecycle.yaml") unless canonical_lifecycle_skills.include?(name)
      end
      error(skill, "missing agents/openai.yaml") unless dir.join("agents/openai.yaml").file?
      error(skill, "skill should have at least one reference") if Dir[dir.join("references/*")].empty?

      validate_skill_references(skill, dir, content)

      metadata_path = dir.join("agents/openai.yaml")
      metadata = load_yaml(metadata_path)
      next unless metadata.is_a?(Hash)
      error(metadata_path, "interface.display_name is required") if metadata.dig("interface", "display_name").to_s.empty?
      short = metadata.dig("interface", "short_description").to_s
      error(metadata_path, "interface.short_description is required") if short.empty?
      error(metadata_path, "short_description exceeds 120 characters") if short.length > 120
      implicit = metadata.dig("policy", "allow_implicit_invocation")
      error(metadata_path, "allow_implicit_invocation must be boolean") unless [true, false].include?(implicit)
    end
  end

  def extract_skill_reference_tokens(content)
    content.scan(/`([^`\n]+)`/).flatten.select { |raw| raw.match?(SKILL_REFERENCE_PATTERN) }
  end

  def validate_skill_references(skill, dir, content)
    extract_skill_reference_tokens(content).each do |raw|
      next if raw.include?("<") || raw.include?("*")

      clean = raw.sub(/[.,;:]\z/, "")
      target = resolve_skill_reference(dir, clean)
      unless target == ROOT || target.to_s.start_with?("#{ROOT}/")
        error(skill, "referenced path escapes repository root: #{clean}")
        next
      end
      error(skill, "referenced path does not exist: #{clean}") unless target.exist?
    end
  end

  def resolve_skill_reference(skill_dir, raw)
    skill_dir.join(raw).cleanpath
  end

  def validate_schema_keyword_support(path, schema)
    scan_schema_keywords(path, schema, schema, "#")
  end

  def validate_route_decision_skill_enum(path, schema)
    enum = Array(schema.dig("properties", "next_skill", "enum"))
    missing = REQUIRED_SKILLS - enum
    extra = enum - REQUIRED_SKILLS
    unless missing.empty?
      error(path, "properties.next_skill.enum missing canonical skills: #{missing.join(', ')}")
    end
    unless extra.empty?
      error(path, "properties.next_skill.enum contains non-canonical skills: #{extra.join(', ')}")
    end
  end

  def scan_schema_keywords(path, node, root_schema, pointer)
    return unless node.is_a?(Hash)

    node.each_key do |key|
      error(path, "unsupported JSON Schema keyword at #{pointer}: #{key}") unless SUPPORTED_SCHEMA_KEYWORDS.include?(key.to_s)
    end

    validate_schema_type(path, node, pointer) if node.key?("type")
    validate_schema_format(path, node, pointer) if node.key?("format")
    validate_schema_pattern(path, node, pointer, "pattern", node["pattern"]) if node.key?("pattern")
    validate_schema_ref(path, root_schema, pointer, node["$ref"]) if node.key?("$ref")
    validate_schema_pattern_properties(path, node, root_schema, pointer)
    validate_schema_dependent_required(path, node, pointer)

    scan_schema_map(path, node["$defs"], root_schema, "#{pointer}/$defs")
    scan_schema_map(path, node["properties"], root_schema, "#{pointer}/properties")
    scan_schema_value(path, node["additionalProperties"], root_schema, "#{pointer}/additionalProperties")
    scan_schema_value(path, node["items"], root_schema, "#{pointer}/items")
    Array(node["prefixItems"]).each_with_index { |item, index| scan_schema_value(path, item, root_schema, "#{pointer}/prefixItems/#{index}") }
    %w[allOf anyOf oneOf].each do |keyword|
      Array(node[keyword]).each_with_index { |item, index| scan_schema_value(path, item, root_schema, "#{pointer}/#{keyword}/#{index}") }
    end
    %w[if then else].each { |keyword| scan_schema_value(path, node[keyword], root_schema, "#{pointer}/#{keyword}") }
  end

  def scan_schema_map(path, map, root_schema, pointer)
    return unless map.is_a?(Hash)

    map.each do |key, child|
      scan_schema_value(path, child, root_schema, "#{pointer}/#{escape_json_pointer(key)}")
    end
  end

  def scan_schema_value(path, value, root_schema, pointer)
    return if value == true || value == false

    if value.is_a?(Hash)
      scan_schema_keywords(path, value, root_schema, pointer)
    elsif !value.nil?
      error(path, "expected schema object or boolean at #{pointer}")
    end
  end

  def validate_schema_type(path, node, pointer)
    types = Array(node["type"]).map(&:to_s)
    unsupported = types - Verdify::SchemaValidator::TYPE_CHECKS.keys
    error(path, "unsupported JSON Schema type at #{pointer}: #{unsupported.join(', ')}") unless unsupported.empty?
  end

  def validate_schema_format(path, node, pointer)
    format = node["format"].to_s
    unless Verdify::SchemaValidator::SUPPORTED_FORMATS.include?(format)
      error(path, "unsupported JSON Schema format at #{pointer}: #{format}")
    end
  end

  def validate_schema_pattern(path, _node, pointer, keyword, pattern)
    Regexp.new(pattern.to_s)
  rescue RegexpError => e
    error(path, "invalid JSON Schema #{keyword} at #{pointer}: #{e.message}")
  end

  def validate_schema_ref(path, root_schema, pointer, ref)
    unless ref.is_a?(String) && ref.start_with?("#")
      error(path, "unsupported JSON Schema $ref at #{pointer}: #{ref.inspect}")
      return
    end

    error(path, "unresolved JSON Schema $ref at #{pointer}: #{ref}") if resolve_json_pointer(root_schema, ref.delete_prefix("#")).nil?
  end

  def validate_schema_pattern_properties(path, node, root_schema, pointer)
    return unless node["patternProperties"].is_a?(Hash)

    node["patternProperties"].each do |pattern, child|
      validate_schema_pattern(path, node, pointer, "patternProperties #{pattern.inspect}", pattern)
      scan_schema_value(path, child, root_schema, "#{pointer}/patternProperties/#{escape_json_pointer(pattern)}")
    end
  end

  def validate_schema_dependent_required(path, node, pointer)
    return unless node["dependentRequired"].is_a?(Hash)

    node["dependentRequired"].each do |key, dependents|
      unless dependents.is_a?(Array) && dependents.all? { |item| item.is_a?(String) }
        error(path, "dependentRequired #{key.inspect} at #{pointer} must be an array of property names")
      end
    end
  end

  def resolve_json_pointer(root, pointer)
    return root if pointer == ""
    return nil unless pointer.start_with?("/")

    pointer.split("/").drop(1).reduce(root) do |current, token|
      key = token.gsub("~1", "/").gsub("~0", "~")
      if current.is_a?(Hash) && current.key?(key)
        current[key]
      elsif current.is_a?(Array) && key.match?(/\A\d+\z/) && current[key.to_i]
        current[key.to_i]
      else
        return nil
      end
    end
  end

  def escape_json_pointer(value)
    value.to_s.gsub("~", "~0").gsub("/", "~1")
  end

  def validate_host_links
    { ".agents/skills" => "Codex", ".claude/skills" => "Claude Code" }.each do |relative, host|
      REQUIRED_SKILLS.each do |name|
        link = ROOT.join(relative, name)
        source = ROOT.join("skills", name)
        unless link.symlink?
          error(link, "#{host} entry must be a symlink")
          next
        end
        begin
          error(link, "#{host} entry resolves outside canonical skill") unless link.realpath == source.realpath
        rescue Errno::ENOENT
          error(link, "#{host} entry is broken")
        end
      end
    end
  end

  def validate_workflow
    path = ROOT.join("verdify.workflow.yaml")
    workflow = load_yaml(path)
    return unless workflow.is_a?(Hash)

    error(path, "canonical_lifecycle_source must be config/lifecycle.yaml") unless workflow["canonical_lifecycle_source"] == "config/lifecycle.yaml"
    error(path, "outline_stage_model must be legacy_17_stage_compatibility") unless workflow["outline_stage_model"] == "legacy_17_stage_compatibility"

    stages = workflow["outline_stages"]
    unless stages.is_a?(Array) && stages.length == 17
      error(path, "outline_stages must contain exactly 17 original lifecycle stages")
      return
    end
    ids = stages.map { |stage| stage["id"] }
    error(path, "outline stage IDs must be 1..17") unless ids == (1..17).to_a
    stages.each do |stage|
      error(path, "stage #{stage['id']} references unknown lifecycle skill #{stage['skill']}") unless canonical_lifecycle_skills.include?(stage["skill"])
      validate_mode_membership(path, stage["skill"], stage["mode"], "outline stage #{stage['id']}")
    end

    machine = workflow["state_machine"]
    states = machine.is_a?(Hash) ? machine["states"] : nil
    unless states.is_a?(Hash) && !states.empty?
      error(path, "state_machine.states is required")
      return
    end
    initial = machine["initial"]
    error(path, "initial state does not exist") unless states.key?(initial)
    states.each do |name, node|
      next unless node.is_a?(Hash)
      if node["skill"]
        error(path, "state #{name} references unknown lifecycle skill") unless canonical_lifecycle_skills.include?(node["skill"])
        validate_mode_membership(path, node["skill"], node["mode"], "state #{name}")
      end
      Array(node["transitions"]).each do |target|
        error(path, "state #{name} transitions to unknown state #{target}") unless states.key?(target)
      end
    end

    child = workflow.dig("lane_child_workflow", "states")
    if child.is_a?(Hash)
      child.each do |name, node|
        Array(node["next"]).each do |target|
          # PLAN_SPRINT is an intentional parent-workflow escape.
          next if target == "PLAN_SPRINT"
          error(path, "lane child state #{name} transitions to unknown state #{target}") unless child.key?(target)
        end
      end
    else
      error(path, "lane_child_workflow.states is required")
    end
  end

  def validate_cli_lifecycle_alignment
    path = ROOT.join("lib/verdify/cli.rb")
    unless Verdify::CLI::SKILLS == canonical_lifecycle_skills
      error(path, "Verdify::CLI::SKILLS must match config/lifecycle.yaml skills order")
    end

    content = path.read
    content.scan(/route_hash\(\s*repo,\s*"[^"]+",\s*"([^"]+)",\s*"([^"]+)"/m).each do |skill, mode|
      validate_mode_membership(path, skill, mode, "route_hash")
    end

    workflow = load_yaml(ROOT.join("verdify.workflow.yaml"))
    return unless workflow.is_a?(Hash)

    Array(workflow["gate_types"]).each do |type|
      skill, mode = Verdify::CLI.new([]).send(:route_for_gate, type)
      validate_mode_membership(path, skill, mode, "route_for_gate #{type}")
    end
  end

  def validate_github_templates
    problem = load_yaml(ROOT.join(".github/ISSUE_TEMPLATE/problem.yml"))
    if problem.is_a?(Hash)
      ids = Array(problem["body"]).map { |item| item["id"] if item.is_a?(Hash) }.compact
      %w[problem desired_outcome acceptance dependencies risk evidence].each do |id|
        error(ROOT.join(".github/ISSUE_TEMPLATE/problem.yml"), "missing field #{id}") unless ids.include?(id)
      end
    end

    template = ROOT.join(".github/pull_request_template.md")
    body = template.file? ? template.read : ""
    REQUIRED_PR_SECTIONS.each do |section|
      error(template, "missing required section ## #{section}") unless body.match?(/^##\s+#{Regexp.escape(section)}\s*$/i)
    end
    error(template, "must include a closing issue keyword") unless body.match?(/Closes\s+#/i)
    error(template, "must include current head SHA evidence") unless body.include?("Current head SHA")

    codeowners = ROOT.join(".github/CODEOWNERS")
    if codeowners.file? && codeowners.read.lines.any? { |line| line.strip.match?(/\A[^#].*@[\w-]+/) }
      warning(codeowners, "contains active owners; verify they are valid for the destination repository")
    end
  end

  def validate_evaluations
    REQUIRED_SKILLS.each do |skill|
      path = ROOT.join("evaluations", skill, "evals.json")
      unless path.file?
        error(path, "missing evaluation pack")
        next
      end
      data = load_json(path)
      next unless data.is_a?(Hash)
      error(path, "skill_name does not match") unless data["skill_name"] == skill
      evals = data["evals"]
      unless evals.is_a?(Array) && evals.length >= 2
        error(path, "must contain at least two evaluations")
        next
      end
      ids = evals.map { |item| item["id"] }
      error(path, "evaluation IDs must be unique") unless ids.uniq.length == ids.length
      evals.each do |item|
        %w[id prompt expected_output assertions].each do |key|
          error(path, "evaluation #{item['id'].inspect} missing #{key}") if item[key].nil? || (item[key].respond_to?(:empty?) && item[key].empty?)
        end
        error(path, "evaluation #{item['id']} should have at least three assertions") unless Array(item["assertions"]).length >= 3
      end
    end
  end

  def validate_scripts
    script_paths = %w[
      bin/verdify scripts/setup-agent-hosts.rb scripts/validate-repo.rb scripts/pr-policy.rb
      scripts/release-preflight.rb
      scripts/bootstrap-agent-session.sh scripts/launch-codex.sh scripts/launch-claude.sh scripts/package.sh scripts/verify-package.sh
      npm/bin/verdify.js tests/test_npm_install.sh tests/test_release_preflight.sh
    ].map { |relative| ROOT.join(relative) }
    script_paths += Dir[ROOT.join("skills/*/scripts/*")].sort.map { |path| Pathname.new(path) }.select(&:file?)

    script_paths.each do |path|
      relative = rel(path)
      path = ROOT.join(relative)
      next unless path.file?
      error(path, "must be executable") unless path.executable?
      if path.extname == ".rb" || relative == "bin/verdify"
        error(path, "Ruby syntax check failed") unless system("ruby", "-c", path.to_s, out: File::NULL, err: File::NULL)
      elsif path.extname == ".sh"
        error(path, "Bash syntax check failed") unless system("bash", "-n", path.to_s, out: File::NULL, err: File::NULL)
      elsif path.extname == ".js"
        error(path, "JavaScript syntax check failed") unless system("node", "--check", path.to_s, out: File::NULL, err: File::NULL)
      end
    end
  end

  def validate_examples
    root = ROOT.join("examples/minimal-project/.agent-workflow")
    error(root, "complete example project is missing") unless root.directory?
    artifact_paths = Dir[root.join("**/*.{yaml,yml,json}")].sort.map { |p| Pathname.new(p) }
    artifact_paths.each do |path|
      document = path.extname == ".json" ? load_json(path) : load_yaml(path)
      next unless document.is_a?(Hash) && document["schema_ref"]
      ref = document["schema_ref"].to_s
      if ref.include?("/") || ref.include?("..")
        error(path, "schema_ref must be a schema filename")
        next
      end
      schema_path = ROOT.join("schemas", ref)
      unless schema_path.file?
        error(path, "schema_ref does not exist: #{ref}")
        next
      end
      Verdify::SchemaValidator.validate_file(path, schema_path).each { |message| error(path, message) }
      Verdify::SemanticValidator.validate(document).each { |message| error(path, message) }
    rescue Verdify::Error => e
      error(path, e.message)
    end

    validate_example_semantics(root)
  end

  def validate_example_semantics(root)
    plan_path = root.join("sprints/2026-06-22-a/sprint-plan.yaml")
    return unless plan_path.file?
    plan = load_yaml(plan_path)
    return unless plan.is_a?(Hash)
    if %w[approved active complete].include?(plan["status"])
      %w[issue_ids scope acceptance_criteria lanes].each do |field|
        error(plan_path, "approved sprint requires non-empty #{field}") if Array(plan[field]).empty?
      end
      if Array(plan.dig("review_plan", "user_stories_for_review")).empty?
        error(plan_path, "approved sprint requires review_plan.user_stories_for_review")
      end
      if Array(plan.dig("review_plan", "human_review_milestones")).empty?
        error(plan_path, "approved sprint requires review_plan.human_review_milestones")
      end
      error(plan_path, "approved sprint requires approved approval") unless plan.dig("approval", "status") == "approved"
    end

    assignments = Hash.new { |h, k| h[k] = [] }
    Array(plan["lanes"]).each do |lane|
      Array(lane["issue_ids"]).each { |issue| assignments[issue] << lane["lane_id"] }
      contract_path = root.parent.parent.join(lane["contract_path"].to_s.sub(/\A\.agent-workflow\//, ".agent-workflow/"))
      # The example root already points at .agent-workflow; normalize directly if needed.
      contract_path = root.join(lane["contract_path"].to_s.sub(/\A\.agent-workflow\//, "")) unless contract_path.file?
      error(plan_path, "lane contract missing: #{lane['contract_path']}") unless contract_path.file?
    end
    assignments.each do |issue, lanes|
      error(plan_path, "issue ##{issue} appears in multiple lanes: #{lanes.join(', ')}") if lanes.uniq.length > 1
    end

    contract_path = root.join("sprints/2026-06-22-a/lanes/contracts/issue-123-api.contract.yaml")
    closeout_path = root.join("sprints/2026-06-22-a/lanes/closeout/issue-123-api.closeout.yaml")
    critic_path = root.join("sprints/2026-06-22-a/critic/issue-123-api.critic.yaml")
    if contract_path.file?
      contract = load_yaml(contract_path)
      error(contract_path, "must enforce one coding session per worktree") unless contract.dig("worktree_policy", "one_coding_session_per_worktree") == true
      error(contract_path, "must require worktree lock") unless contract.dig("worktree_policy", "lock_required") == true
      if Array(contract["issue_ids"]).length > 1 && contract["coupling_justification"].to_s.strip.empty?
        error(contract_path, "multi-issue lane requires coupling justification")
      end
    end
    if closeout_path.file? && critic_path.file?
      closeout = load_yaml(closeout_path)
      critic = load_yaml(critic_path)
      error(critic_path, "critic session must differ from worker session") if critic["critic_session_id"] == closeout["worker_session_id"]
      error(critic_path, "critic must review the closeout head SHA") unless critic["reviewed_head_sha"] == closeout["head_sha"]
    end
  end

  def validate_no_canonical_duplicates
    candidates = Dir[ROOT.join("{schemas,skills}/**/*")].map { |p| Pathname.new(p) }.select(&:file?).reject(&:symlink?)
    groups = candidates.select { |p| p.size > 256 }.group_by { |p| Digest::SHA256.file(p).hexdigest }
    groups.each_value do |paths|
      next if paths.length < 2
      error(paths.first, "exact duplicate canonical content also appears at #{paths.drop(1).map { |p| rel(p) }.join(', ')}")
    end
  end

  def report
    unless warnings.empty?
      puts "Warnings:"
      warnings.sort.each { |item| puts "  - #{item}" }
    end
    unless errors.empty?
      puts "Errors:"
      errors.sort.each { |item| puts "  - #{item}" }
      exit 1
    end
    puts "Verdify repository validation passed (#{REQUIRED_SKILLS.length} skills, #{@schema_ids.length} schemas)."
  end
end

RepoValidator.new.run if $PROGRAM_NAME == __FILE__
