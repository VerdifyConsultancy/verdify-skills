# frozen_string_literal: true

module Verdify
  # ComplianceAssessor is the consumer-facing analogue of scripts/validate-repo.rb.
  #
  # validate-repo.rb validates THIS PACKAGE; ComplianceAssessor validates that an
  # INSTALLED repository conforms to the fleet standard shape. It is hermetic
  # (no network, no gh token in the default path), deterministic, and gem-free.
  #
  # It produces a schema-valid ComplianceAssessment (schemas/compliance-assessment.schema.yaml)
  # and is the single scriptable shell behind the `verdify gate compliance` command
  # and the reusable .github/workflows/compliance-gate.yml CI job.
  class ComplianceAssessor
    # Canonical North Star layout owned by config/authority-matrix.yaml.
    # NOT the hypothesized .agent-workflow/northstar/NORTHSTAR_PRODUCT.md, which does
    # not exist in standardized repos and would false-fail every conforming repo.
    NORTHSTAR_DOC_FILES = [
      ".agent-workflow/project/product.md",
      ".agent-workflow/architecture/north-star-architecture.md"
    ].freeze
    NORTHSTAR_YAML_FILES = {
      ".agent-workflow/project/project-definition.yaml" => "project-definition.schema.yaml",
      ".agent-workflow/architecture/architecture.yaml" => "architecture.schema.yaml"
    }.freeze
    APPROVAL_STATES = %w[approved pending blocked].freeze

    # The standard AGENTS.md managed block markers. `verdify init`/onboarding writes the
    # marker pair; the gate asserts presence + ordering + non-empty managed content.
    AGENTS_BEGIN_MARKER = /<!--\s*BEGIN VERDIFY[^>]*-->/
    AGENTS_END_MARKER = /<!--\s*END VERDIFY[^>]*-->/

    # Vendored install footprint (see README "Install in a target repository").
    VENDOR_ROOT = ".agent-skills/verdify-skills"
    VERSION_DIR_PATTERN = /\A\d+\.\d+\.\d+(?:[.+-].*)?\z/
    DISCOVERY_DIRS = [".agents/skills", ".claude/skills"].freeze

    # Hermetic working-tree secret patterns. History scanning stays in the dedicated
    # secret-scan.yml workflow; a clean gate must NOT be misread as history-clean.
    SECRET_LINE_PATTERNS = [
      ["private key block", /-----BEGIN (?:[A-Z0-9]+ )*PRIVATE KEY-----/],
      ["AWS access key ID", /\b(?:AKIA|ASIA)[0-9A-Z]{16}\b/],
      ["Google API key", /\bAIza[0-9A-Za-z_-]{35}\b/],
      ["GitHub token", /\b(?:ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9_]{36,}\b/],
      ["GitHub fine-grained token", /\bgithub_pat_[A-Za-z0-9_]{20,}_[A-Za-z0-9_]{20,}\b/],
      ["OpenAI API key", /\bsk-(?:proj-)?[A-Za-z0-9_-]{20,}\b/],
      ["Slack token", /\bxox[baprs]-[A-Za-z0-9-]{20,}\b/]
    ].freeze
    SECRET_SCAN_MAX_BYTES = 1_048_576

    def initialize(repo:, strict: true, snapshot_path: nil)
      @repo = repo
      @strict = strict
      @snapshot_path = snapshot_path
    end

    # Returns a ComplianceAssessment hash (schema_ref compliance-assessment.schema.yaml).
    def assess
      checks = [
        check_agents_markers,
        check_northstar_present,
        check_vendored_skills,
        check_no_committed_secrets,
        check_access_project_block
      ]
      checks << check_github_reconcile if @snapshot_path

      required_failed = checks.count { |c| c["required"] && c["status"] == "fail" }
      passed = checks.count { |c| c["status"] == "pass" }
      failed = checks.count { |c| c["status"] == "fail" }
      ok = required_failed.zero?

      {
        "schema_ref" => "compliance-assessment.schema.yaml",
        "kind" => "ComplianceAssessment",
        "schema_version" => "1.0",
        "repository" => @repo.github_slug || "local/#{@repo.root.basename}",
        "assessed_at" => Verdify.utc_now,
        "verdify_version" => Verdify::VERSION,
        "strict" => @strict,
        "ok" => ok,
        "summary" => {
          "total" => checks.length,
          "passed" => passed,
          "failed" => failed,
          "required_failed" => required_failed
        },
        "checks" => checks
      }
    end

    private

    def repo_path(relative)
      @repo.root.join(relative)
    end

    def check_record(id, title, ok, required, details, evidence = [])
      {
        "id" => id,
        "title" => title,
        "status" => ok ? "pass" : "fail",
        "required" => required,
        "details" => Array(details),
        "evidence" => Array(evidence)
      }
    end

    def check_agents_markers
      path = repo_path("AGENTS.md")
      unless path.file?
        return check_record("agents_markers", "AGENTS.md managed marker block", false, true,
                            ["AGENTS.md is missing at the repository root"])
      end

      text = path.read
      begin_match = text.match(AGENTS_BEGIN_MARKER)
      end_match = text.match(AGENTS_END_MARKER)
      details = []
      details << "AGENTS.md is missing the BEGIN VERDIFY marker comment" unless begin_match
      details << "AGENTS.md is missing the END VERDIFY marker comment" unless end_match
      if begin_match && end_match
        if begin_match.begin(0) >= end_match.begin(0)
          details << "AGENTS.md END VERDIFY marker appears before BEGIN VERDIFY marker"
        else
          managed = text[begin_match.end(0)...end_match.begin(0)].to_s.strip
          details << "AGENTS.md managed block between markers is empty" if managed.empty?
        end
      end
      check_record("agents_markers", "AGENTS.md managed marker block", details.empty?, true, details, ["AGENTS.md"])
    end

    def check_northstar_present
      details = []
      evidence = []
      NORTHSTAR_DOC_FILES.each do |relative|
        if repo_path(relative).file?
          evidence << relative
        else
          details << "missing North Star document #{relative}"
        end
      end

      NORTHSTAR_YAML_FILES.each do |relative, schema_name|
        path = repo_path(relative)
        unless path.file?
          details << "missing North Star artifact #{relative}"
          next
        end
        evidence << relative
        document = safe_load(path)
        unless document.is_a?(Hash)
          details << "#{relative} is not a valid YAML mapping"
          next
        end
        errors = SchemaValidator.validate_file(path, Verdify::ROOT.join("schemas", schema_name))
        unless errors.empty?
          details << "#{relative} is not schema-valid (#{schema_name}): #{errors.first}"
        end
        status = document.dig("approval", "status").to_s
        unless APPROVAL_STATES.include?(status)
          details << "#{relative} approval.status #{status.inspect} is not one of #{APPROVAL_STATES.join(', ')}"
        end
      end

      check_record("northstar_present", "North Star present at authority-matrix canonical paths",
                   details.empty?, true, details, evidence)
    rescue Verdify::Error => e
      check_record("northstar_present", "North Star present at authority-matrix canonical paths",
                   false, true, ["North Star artifact could not be parsed: #{e.message}"])
    end

    def check_vendored_skills
      details = []
      evidence = []
      vendor_root = repo_path(VENDOR_ROOT)
      unless vendor_root.directory?
        return check_record("vendored_skills", "verdify-skills vendored and discovery symlinks resolve",
                            false, true, ["missing vendored package directory #{VENDOR_ROOT}"])
      end

      version_dirs = vendor_root.children.select do |child|
        child.directory? && child.basename.to_s.match?(VERSION_DIR_PATTERN)
      end
      installed = version_dirs.find { |dir| dir.join("bin/verdify").file? }
      if installed
        evidence << installed.join("bin/verdify").relative_path_from(@repo.root).to_s
      else
        details << "no vendored version under #{VENDOR_ROOT}/<version> contains bin/verdify"
      end

      symlinks = discovery_symlinks
      if symlinks.empty?
        details << "no host discovery symlinks found under #{DISCOVERY_DIRS.join(' or ')}"
      end
      symlinks.each do |link|
        relative = link.relative_path_from(@repo.root).to_s
        begin
          target = link.realpath
        rescue Errno::ENOENT
          details << "discovery symlink #{relative} is broken"
          next
        end
        if target.to_s.start_with?("#{vendor_root.realpath}/") || target.to_s == vendor_root.realpath.to_s
          evidence << relative
        else
          details << "discovery symlink #{relative} resolves outside #{VENDOR_ROOT}"
        end
      end

      check_record("vendored_skills", "verdify-skills vendored and discovery symlinks resolve",
                   details.empty?, true, details, evidence)
    end

    def discovery_symlinks
      DISCOVERY_DIRS.flat_map do |relative|
        dir = repo_path(relative)
        next [] unless dir.directory?

        dir.children.select(&:symlink?)
      end
    end

    def check_no_committed_secrets
      findings = []
      tracked_files.each do |relative|
        path = repo_path(relative)
        next unless path.file?
        next if path.symlink?
        next if path.size > SECRET_SCAN_MAX_BYTES

        scan_file_for_secrets(path).each do |type, line_number|
          findings << "#{relative}:#{line_number} #{type}"
        end
        break if findings.length >= 20
      end

      check_record("no_committed_secrets", "no committed secret material in tracked files",
                   findings.empty?, true, findings.first(20),
                   ["working-tree scan only; history scanning stays in secret-scan.yml"])
    end

    def tracked_files
      stdout, _stderr, status = @repo.git("ls-files", "-z")
      return [] unless status.success?

      stdout.split("\x00").reject(&:empty?)
    rescue Verdify::Error
      []
    end

    def scan_file_for_secrets(path)
      text = File.binread(path).encode("UTF-8", invalid: :replace, undef: :replace, replace: "?")
      findings = []
      text.each_line.with_index(1) do |line, line_number|
        SECRET_LINE_PATTERNS.each do |type, pattern|
          findings << [type, line_number] if line.match?(pattern)
        end
      end
      findings
    end

    def check_access_project_block
      relative = ".agent-workflow/project/project-definition.yaml"
      path = repo_path(relative)
      unless path.file?
        return check_record("access_project_block", "access/project authority block",
                            false, true, ["missing #{relative} (approved_project_definition authority)"])
      end

      document = safe_load(path)
      details = []
      if document.is_a?(Hash)
        details << "#{relative} is missing project_id" if document["project_id"].to_s.empty?
        approval = document["approval"]
        if !approval.is_a?(Hash)
          details << "#{relative} is missing an approval block"
        elsif !APPROVAL_STATES.include?(approval["status"].to_s)
          details << "#{relative} approval.status #{approval['status'].inspect} is not one of #{APPROVAL_STATES.join(', ')}"
        elsif approval["status"].to_s == "approved" && approval["approver"].to_s.empty?
          details << "#{relative} approved project definition is missing an approver"
        end
      else
        details << "#{relative} is not a valid YAML mapping"
      end

      check_record("access_project_block", "access/project authority block",
                   details.empty?, true, details, [relative])
    rescue Verdify::Error => e
      check_record("access_project_block", "access/project authority block",
                   false, true, ["#{relative} could not be parsed: #{e.message}"])
    end

    # Optional, opt-in cross-check. Only runs when --snapshot is supplied so the default
    # gate path stays hermetic (no gh/network call) per the durability discipline.
    def check_github_reconcile
      path = Pathname.new(@snapshot_path)
      path = @repo.root.join(path) unless path.absolute?
      unless path.file?
        return check_record("github_snapshot", "github snapshot present for reconcile cross-check",
                            false, false, ["snapshot not found: #{@snapshot_path}"])
      end

      document = SchemaValidator.load_document(path)
      errors = SchemaValidator.validate_file(path, Verdify::ROOT.join("schemas/github-snapshot.schema.yaml"))
      details = errors.empty? ? [] : ["snapshot is not schema-valid: #{errors.first}"]
      kind_ok = document.is_a?(Hash) && document["kind"] == "GitHubSnapshot"
      details << "snapshot kind is not GitHubSnapshot" unless kind_ok
      check_record("github_snapshot", "github snapshot present for reconcile cross-check",
                   details.empty?, false, details, [@snapshot_path.to_s])
    rescue Verdify::Error => e
      check_record("github_snapshot", "github snapshot present for reconcile cross-check",
                   false, false, ["snapshot could not be parsed: #{e.message}"])
    end

    def safe_load(path)
      Verdify.safe_load_yaml(path)
    end
  end
end
