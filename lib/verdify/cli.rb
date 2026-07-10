# frozen_string_literal: true

require "tmpdir"

module Verdify
  class CLI
    SKILLS = %w[
      project-router
      repo-bootstrap
      transcript-replan
      northstar-research-ingest
      northstar-planning
      northstar-interview
      northstar-question-resolution
      project-definition
      architecture-contracts
      state-of-union
      repo-hygiene
      sprint-planning
      sprint-replan
      sprint-orchestrator
      controller-loop
      subagent-worktree
      platform-readiness
      gravity-readiness
      lane-delivery
      independent-critic
      controller-merge
      release-verification
      sprint-handoff
      adversarial-audit
      consensus-audit-workflow
    ].freeze
    SECRET_SCAN_LINE_PATTERNS = [
      ["private key block", /-----BEGIN (?:[A-Z0-9]+ )*PRIVATE KEY-----/],
      ["AWS access key ID", /\b(?:AKIA|ASIA)[0-9A-Z]{16}\b/],
      ["Google API key", /\bAIza[0-9A-Za-z_-]{35}\b/],
      ["GitHub token", /\b(?:ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9_]{36,}\b/],
      ["GitHub fine-grained token", /\bgithub_pat_[A-Za-z0-9_]{20,}_[A-Za-z0-9_]{20,}\b/],
      ["OpenAI API key", /\bsk-(?:proj-)?[A-Za-z0-9_-]{20,}\b/],
      ["Slack token", /\bxox[baprs]-[A-Za-z0-9-]{20,}\b/],
      ["JWT bearer token", /\beyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\b/],
      ["US Social Security number", /\b(?!000|666|9\d\d)\d{3}-(?!00)\d{2}-(?!0000)\d{4}\b/]
    ].freeze
    SECRET_ASSIGNMENT_PATTERN = /\b(?:api[_-]?key|access[_-]?key|secret(?:[_-]?key)?|client[_-]?secret|auth[_-]?token|refresh[_-]?token|password|passwd|pwd|bearer[_-]?token|private[_-]?key)\b\s*(?:=|:|=>)\s*["']?([A-Za-z0-9+\/=_\-.]{20,})["']?/i
    CREDIT_CARD_CANDIDATE_PATTERN = /\b(?:\d[ -]*?){13,19}\b/

    def self.run(argv)
      new(argv.dup).run
    rescue UsageError => e
      warn "verdify: #{e.message}"
      2
    rescue CommandError => e
      warn "verdify: #{e.message}"
      e.status
    rescue Error => e
      warn "verdify: #{e.message}"
      1
    rescue Interrupt
      warn "verdify: interrupted"
      130
    end

    def initialize(argv)
      @argv = argv
    end

    def run
      command = @argv.shift
      case command
      when nil, "help", "--help", "-h"
        puts help
        0
      when "--version", "version", "-v"
        puts Verdify::VERSION
        0
      when "doctor" then command_doctor
      when "init" then command_init
      when "route" then command_route
      when "artifact" then command_artifact
      when "northstar" then command_northstar
      when "sprint" then command_sprint
      when "lane" then command_lane
      when "prompt" then command_prompt
      when "github" then command_github
      when "gate" then command_gate
      when "pack" then command_pack
      when "dl"
        pack_name = @argv.shift
        if pack_name&.start_with?("-")
          @argv.unshift(pack_name)
          pack_name = nil
        end
        command_pack_install(pack_name)
      else
        raise UsageError, "unknown command #{command.inspect}\n\n#{help}"
      end
    end

    private

    def help
      <<~HELP
        Verdify lifecycle CLI #{Verdify::VERSION}

        Usage: bin/verdify <command> [options]

        Commands:
          doctor                     Check target repository prerequisites
          init                       Initialize .agent-workflow in a target repository
          route                      Determine and optionally write the next skill/mode
          artifact validate          Validate an artifact against its schema_ref
          northstar ingest-research  Register research in the North Star evidence registry
          northstar evidence list    Query registered North Star evidence
          sprint init                Create a draft sprint skeleton and approval gate
          sprint receipt             Generate a protected-dev terminal receipt transaction
          lane create                Create and lock one worker worktree/lease
          lane review                Create a fresh detached critic worktree/lease
          lane list                  List local Verdify leases and Git worktrees
          lane inspect               Inspect one lease and worktree status
          lane release               Release a lease and normally remove its worktree
          prompt compile             Compile a worker or critic prompt with input hashes
          github bootstrap           Preview/apply standard Verdify labels
          github snapshot            Cache current issues and pull requests locally
          github reconcile           Compare sprint lane contracts with a snapshot
          gate compliance            Assess fleet-standard-shape conformance of a repo
          pack list                  List skill packs in this registry package
          pack install               Link one skill pack into a target repository
          dl                         Shortcut for `pack install --pack NAME`

        Run `bin/verdify <command> --help` for command options.
      HELP
    end

    def parse_options(parser)
      parser.parse!(@argv)
      raise UsageError, "unexpected arguments: #{@argv.join(' ')}" unless @argv.empty?
    rescue OptionParser::ParseError => e
      raise UsageError, "#{e.message}\n#{parser}"
    end

    def command_doctor
      options = { repo: Dir.pwd, json: false }
      parser = OptionParser.new do |o|
        o.banner = "Usage: bin/verdify doctor [--repo PATH] [--json]"
        o.on("--repo PATH", "Target Git repository") { |v| options[:repo] = v }
        o.on("--json", "Emit JSON") { options[:json] = true }
        o.on("-h", "--help") { puts o; return 0 }
      end
      parse_options(parser)

      checks = []
      ruby_major, ruby_minor = RUBY_VERSION.split(".").first(2).map(&:to_i)
      ruby_ok = ruby_major > 3 || (ruby_major == 3 && ruby_minor >= 1)
      checks << check_record("ruby", ruby_ok, true, RUBY_VERSION)
      checks << check_record("git", command_available?("git"), true, executable_path("git"))
      checks << check_record("gh", command_available?("gh"), false, executable_path("gh") || "not installed")

      begin
        repo = GitRepository.new(options[:repo])
        checks << check_record("git_repository", true, true, repo.root.to_s)
        checks << check_record("default_branch", !repo.default_branch.to_s.empty?, true, repo.default_branch)
        checks << check_record("working_tree_clean", repo.clean?, false, repo.clean? ? "clean" : "dirty")
        checks << check_record("agent_workflow_initialized", repo.root.join(".agent-workflow").directory?, false,
                               repo.root.join(".agent-workflow").directory? ? "present" : "run verdify init")
      rescue UsageError => e
        checks << check_record("git_repository", false, true, e.message)
      end

      result = {
        "verdify_version" => Verdify::VERSION,
        "checked_at" => Verdify.utc_now,
        "checks" => checks
      }
      if options[:json]
        puts JSON.pretty_generate(result)
      else
        checks.each do |check|
          marker = check["ok"] ? "OK" : (check["required"] ? "FAIL" : "WARN")
          puts format("%-4s %-24s %s", marker, check["name"], check["detail"])
        end
      end
      checks.any? { |c| c["required"] && !c["ok"] } ? 1 : 0
    end

    def command_init
      options = { repo: Dir.pwd, force: false }
      parser = OptionParser.new do |o|
        o.banner = "Usage: bin/verdify init [--repo PATH] [--force]"
        o.on("--repo PATH", "Target Git repository") { |v| options[:repo] = v }
        o.on("--force", "Replace Verdify-owned starter files") { options[:force] = true }
        o.on("-h", "--help") { puts o; return 0 }
      end
      parse_options(parser)
      repo = GitRepository.new(options[:repo])
      root = repo.root.join(".agent-workflow")
      FileUtils.mkdir_p(root)

      files = {
        root.join(".gitignore") => "github/snapshot.json\nruntime/\n*.tmp\nnorthstar/collateral/sources/\n",
        root.join("README.md") => <<~MD,
          # Verdify project artifacts

          Canonical approved definitions, architecture, module contracts, sprint contracts, gates, status, and evidence live here. GitHub Issues remain the backlog and GitHub remains the delivery control plane. `github/snapshot.json` is an ignored cache.
        MD
        root.join("config.yaml") => YAML.dump({
          "schema_ref" => "project-config.schema.yaml",
          "kind" => "VerdifyProjectConfig",
          "schema_version" => "1.0",
          "initialized_at" => Verdify.utc_now,
          "default_branch" => repo.default_branch,
          "github_repository" => repo.github_slug,
          "policy" => {
            "one_issue_per_lane" => true,
            "one_coding_session_per_worktree" => true,
            "fresh_critic_required" => true,
            "runtime_verification_required" => true
          }
        })
      }

      files.each do |path, content|
        if path.exist? && !options[:force]
          puts "keep #{path.relative_path_from(repo.root)}"
        else
          Verdify.atomic_write(path, content)
          puts "write #{path.relative_path_from(repo.root)}"
        end
      end

      %w[
        router project architecture/decisions modules/contracts sprints github
        northstar/collateral/sources northstar/research-inbox
      ].each { |relative| FileUtils.mkdir_p(root.join(relative)) }

      puts "Verdify initialized in #{repo.root}"
      0
    end

    def command_route
      options = { repo: Dir.pwd, sprint: nil, write: false, json: false }
      parser = OptionParser.new do |o|
        o.banner = "Usage: bin/verdify route [--repo PATH] [--sprint ID] [--write] [--json]"
        o.on("--repo PATH", "Target Git repository") { |v| options[:repo] = v }
        o.on("--sprint ID", "Select one active sprint when concurrent sprint transactions exist") { |v| options[:sprint] = v }
        o.on("--write", "Write route-decision YAML and Markdown") { options[:write] = true }
        o.on("--json", "Emit JSON instead of YAML") { options[:json] = true }
        o.on("-h", "--help") { puts o; return 0 }
      end
      parse_options(parser)
      repo = GitRepository.new(options[:repo])
      decision = build_route_decision(repo, requested_sprint_id: options[:sprint])
      validate_hash!(decision, "route-decision.schema.yaml", "generated route decision")

      if options[:write]
        dir = repo.root.join(".agent-workflow/router")
        FileUtils.mkdir_p(dir)
        Verdify.atomic_write(dir.join("route-decision.yaml"), YAML.dump(decision))
        markdown = <<~MD
          # Route decision

          - Current state: `#{decision['current_state']}`
          - Next skill: `#{decision['next_skill']}`
          - Next mode: `#{decision['next_mode']}`

          #{decision['reason']}

          ## Missing artifacts

          #{decision['missing_artifacts'].empty? ? 'None.' : decision['missing_artifacts'].map { |item| "- #{item}" }.join("\n")}

          ## Open gates

          #{decision['open_gates'].empty? ? 'None.' : decision['open_gates'].map { |item| "- #{item}" }.join("\n")}
        MD
        Verdify.atomic_write(dir.join("route-decision.md"), markdown)
      end

      puts(options[:json] ? JSON.pretty_generate(decision) : YAML.dump(decision))
      0
    end

    def command_artifact
      subcommand = @argv.shift
      raise UsageError, "Usage: bin/verdify artifact validate --file PATH [--schema PATH]" unless subcommand == "validate"

      options = { file: nil, schema: nil }
      parser = OptionParser.new do |o|
        o.banner = "Usage: bin/verdify artifact validate --file PATH [--schema PATH]"
        o.on("--file PATH", "YAML or JSON artifact") { |v| options[:file] = v }
        o.on("--schema PATH", "Schema path; inferred from schema_ref when omitted") { |v| options[:schema] = v }
        o.on("-h", "--help") { puts o; return 0 }
      end
      parse_options(parser)
      raise UsageError, "--file is required" unless options[:file]

      file = Pathname.new(options[:file]).expand_path
      raise UsageError, "artifact does not exist: #{file}" unless file.file?
      document = SchemaValidator.load_document(file)
      schema = if options[:schema]
                 Pathname.new(options[:schema]).expand_path
               else
                 ref = document.is_a?(Hash) && document["schema_ref"]
                 raise UsageError, "artifact has no schema_ref; pass --schema" if ref.to_s.empty?
                 Verdify::ROOT.join("schemas", ref)
               end
      raise UsageError, "schema does not exist: #{schema}" unless schema.file?
      errors = SchemaValidator.validate_file(file, schema)
      errors.concat(SemanticValidator.validate(document))
      if errors.empty?
        puts "valid #{file} (#{schema.basename})"
        0
      else
        warn errors.map { |e| "#{file}: #{e}" }.join("\n")
        1
      end
    end

    def command_pack
      subcommand = @argv.shift
      case subcommand
      when "list" then command_pack_list
      when "install" then command_pack_install
      else
        raise UsageError, "Usage: bin/verdify pack <list|install>"
      end
    end

    def command_pack_list
      options = { json: false }
      parser = OptionParser.new do |o|
        o.banner = "Usage: bin/verdify pack list [--json]"
        o.on("--json", "Emit JSON") { options[:json] = true }
        o.on("-h", "--help") { puts o; return 0 }
      end
      parse_options(parser)
      packs = skill_packs.map do |pack|
        {
          "name" => pack["name"],
          "display_name" => pack["display_name"],
          "category" => pack["category"],
          "maturity" => pack["maturity"],
          "required_skills" => Array(pack.dig("includes", "required")),
          "optional_skills" => Array(pack.dig("includes", "optional")),
          "capabilities" => Array(pack.dig("provides", "capabilities"))
        }
      end
      if options[:json]
        puts JSON.pretty_generate({ "count" => packs.length, "packs" => packs })
      else
        puts format("%-22s %-12s %-12s %s", "PACK", "CATEGORY", "MATURITY", "REQUIRED SKILLS")
        packs.each do |pack|
          puts format("%-22s %-12s %-12s %s",
                      pack["name"], pack["category"], pack["maturity"], pack["required_skills"].join(","))
        end
      end
      0
    end

    def command_pack_install(initial_pack = nil)
      options = {
        repo: Dir.pwd,
        pack: initial_pack,
        host: "codex",
        include_optional: false,
        force: false,
        init_workflow: false
      }
      parser = OptionParser.new do |o|
        o.banner = "Usage: bin/verdify pack install --pack NAME [--repo PATH] [--host codex|claude|all] [--include-optional] [--force] [--init-workflow]"
        o.on("--repo PATH", "Target Git repository") { |v| options[:repo] = v }
        o.on("--pack NAME", "Skill pack to install") { |v| options[:pack] = v }
        o.on("--host HOST", %w[codex claude all], "Host links to write") { |v| options[:host] = v }
        o.on("--include-optional", "Install optional skills declared by the pack") { options[:include_optional] = true }
        o.on("--force", "Replace conflicting links or directories") { options[:force] = true }
        o.on("--init-workflow", "Also initialize .agent-workflow if missing") { options[:init_workflow] = true }
        o.on("-h", "--help") { puts o; return 0 }
      end
      parse_options(parser)
      raise UsageError, "--pack is required" if options[:pack].to_s.empty?

      pack = load_skill_pack(options[:pack])
      selected = pack_skill_names(pack, options[:include_optional])
      repo = GitRepository.new(options[:repo])
      install_pack_transaction(repo.root, pack, selected, options)
      command_init_for_pack(repo, options[:force]) if options[:init_workflow]
      puts "Installed skill pack #{pack['name']} (#{selected.length} skills) into #{repo.root}"
      puts "Hosts: #{options[:host]}"
      puts "Manifest: .agent-skills/verdify-packs/#{pack['name']}.yaml"
      0
    end

    def command_northstar
      subcommand = @argv.shift
      case subcommand
      when "ingest-research" then command_northstar_ingest_research
      when "evidence" then command_northstar_evidence
      else
        raise UsageError, "Usage: bin/verdify northstar <ingest-research|evidence>"
      end
    end

    def command_northstar_ingest_research
      options = {
        repo: Dir.pwd,
        file: nil,
        title: nil,
        summary: nil,
        id: nil,
        source_uri: nil,
        evidence_type: "research_note",
        evidence_status: "observed",
        tags: [],
        claims: [],
        planning_relevance: [],
        limitations: [],
        json: false
      }
      parser = OptionParser.new do |o|
        o.banner = "Usage: bin/verdify northstar ingest-research --file PATH --title TITLE --summary TEXT [options]"
        o.on("--repo PATH", "Target Git repository") { |v| options[:repo] = v }
        o.on("--file PATH", "Research source file to ingest") { |v| options[:file] = v }
        o.on("--title TITLE", "Evidence title") { |v| options[:title] = v }
        o.on("--summary TEXT", "Why this evidence matters") { |v| options[:summary] = v }
        o.on("--id ID", "Stable evidence ID; default is generated") { |v| options[:id] = v }
        o.on("--source-uri URI", "Original source URL or URI") { |v| options[:source_uri] = v }
        o.on("--type TYPE", %w[research_note research_report source_doc benchmark external_reference adversarial_review transcript observation]) { |v| options[:evidence_type] = v }
        o.on("--status STATUS", %w[verified observed reported inferred unknown]) { |v| options[:evidence_status] = v }
        o.on("--tag TAG", "Evidence tag; repeatable or comma-separated") { |v| options[:tags].concat(split_list(v)) }
        o.on("--claim TEXT", "Source-backed claim; repeatable") { |v| options[:claims] << v }
        o.on("--relevance TEXT", "Planning relevance; repeatable") { |v| options[:planning_relevance] << v }
        o.on("--limitation TEXT", "Evidence limitation; repeatable") { |v| options[:limitations] << v }
        o.on("--json", "Emit JSON") { options[:json] = true }
        o.on("-h", "--help") { puts o; return 0 }
      end
      parse_options(parser)
      raise UsageError, "--file is required" if options[:file].to_s.empty?
      raise UsageError, "--title is required" if options[:title].to_s.empty?
      raise UsageError, "--summary is required" if options[:summary].to_s.empty?

      repo = GitRepository.new(options[:repo])
      source = Pathname.new(options[:file]).expand_path
      raise UsageError, "research file does not exist: #{source}" unless source.file?
      scan_research_source_for_secrets!(source)

      root = repo.root.join(".agent-workflow/northstar")
      collateral_dir = root.join("collateral")
      source_dir = collateral_dir.join("sources")
      registry_path = root.join("evidence-registry.yaml")
      FileUtils.mkdir_p(source_dir)

      now = Verdify.utc_now
      evidence_id = options[:id].to_s.empty? ? next_northstar_evidence_id(registry_path, options[:title]) : options[:id]
      unless evidence_id.match?(/\ANSE-[0-9]{8}-[a-z0-9][a-z0-9-]*\z/)
        raise UsageError, "invalid evidence ID: #{evidence_id}"
      end

      registry = load_northstar_registry(repo, registry_path, now)
      if Array(registry["evidence"]).any? { |item| item["id"] == evidence_id }
        raise UsageError, "evidence already exists: #{evidence_id}"
      end

      source_sha = Digest::SHA256.file(source).hexdigest
      copied_source = source_dir.join("#{evidence_id}-#{Verdify.slug(source.basename.to_s, max: 48)}")
      item_path = collateral_dir.join("#{evidence_id}.yaml")
      raise UsageError, "evidence item already exists: #{item_path}" if item_path.exist?
      raise UsageError, "copied source already exists: #{copied_source}" if copied_source.exist?

      FileUtils.cp(source, copied_source)
      reference = "northstar://evidence/#{evidence_id}"
      rel_item = item_path.relative_path_from(repo.root).to_s
      rel_source = copied_source.relative_path_from(repo.root).to_s

      item = {
        "schema_ref" => "northstar-evidence-item.schema.yaml",
        "kind" => "NorthStarEvidenceItem",
        "schema_version" => "1.0",
        "id" => evidence_id,
        "reference" => reference,
        "title" => options[:title],
        "evidence_type" => options[:evidence_type],
        "evidence_status" => options[:evidence_status],
        "ingested_at" => now,
        "source" => {
          "uri" => options[:source_uri],
          "original_path" => source.to_s,
          "copied_path" => rel_source,
          "sha256" => source_sha
        },
        "summary" => options[:summary],
        "tags" => normalize_tags(options[:tags]),
        "claims" => options[:claims],
        "planning_relevance" => options[:planning_relevance],
        "limitations" => options[:limitations]
      }
      validate_hash!(item, "northstar-evidence-item.schema.yaml", "northstar evidence item")

      registry_entry = {
        "id" => evidence_id,
        "reference" => reference,
        "title" => options[:title],
        "evidence_type" => options[:evidence_type],
        "evidence_status" => options[:evidence_status],
        "ingested_at" => now,
        "item_path" => rel_item,
        "copied_source_path" => rel_source,
        "source_uri" => options[:source_uri],
        "source_sha256" => source_sha,
        "summary" => options[:summary],
        "tags" => item["tags"],
        "claims" => options[:claims],
        "planning_relevance" => options[:planning_relevance]
      }
      registry["updated_at"] = now
      registry["evidence"] = Array(registry["evidence"]).reject { |entry| entry["id"] == evidence_id } << registry_entry
      registry["evidence"] = registry["evidence"].sort_by { |entry| entry["id"] }
      validate_hash!(registry, "northstar-evidence-registry.schema.yaml", "northstar evidence registry")

      Verdify.atomic_write(item_path, YAML.dump(item))
      Verdify.atomic_write(registry_path, YAML.dump(registry))

      result = {
        "id" => evidence_id,
        "reference" => reference,
        "item_path" => rel_item,
        "registry_path" => registry_path.relative_path_from(repo.root).to_s,
        "copied_source_path" => rel_source
      }
      if options[:json]
        puts JSON.pretty_generate(result)
      else
        puts "Ingested #{evidence_id}"
        puts "Reference: #{reference}"
        puts "Item: #{rel_item}"
        puts "Registry: #{result['registry_path']}"
        puts "Source copy: #{rel_source}"
      end
      0
    end

    def command_northstar_evidence
      subcommand = @argv.shift
      raise UsageError, "Usage: bin/verdify northstar evidence list [--repo PATH] [--query TEXT] [--tag TAG] [--json]" unless subcommand == "list"

      options = { repo: Dir.pwd, query: nil, tags: [], json: false }
      parser = OptionParser.new do |o|
        o.banner = "Usage: bin/verdify northstar evidence list [--repo PATH] [--query TEXT] [--tag TAG] [--json]"
        o.on("--repo PATH") { |v| options[:repo] = v }
        o.on("--query TEXT") { |v| options[:query] = v }
        o.on("--tag TAG", "Filter by tag; repeatable or comma-separated") { |v| options[:tags].concat(split_list(v)) }
        o.on("--json") { options[:json] = true }
        o.on("-h", "--help") { puts o; return 0 }
      end
      parse_options(parser)
      repo = GitRepository.new(options[:repo])
      registry_path = repo.root.join(".agent-workflow/northstar/evidence-registry.yaml")
      registry = load_northstar_registry(repo, registry_path, Verdify.utc_now)
      entries = Array(registry["evidence"])
      query = options[:query].to_s.downcase
      tags = normalize_tags(options[:tags])
      entries = entries.select { |entry| evidence_entry_matches?(entry, query, tags) }

      result = {
        "registry_path" => registry_path.relative_path_from(repo.root).to_s,
        "count" => entries.length,
        "evidence" => entries
      }
      if options[:json]
        puts JSON.pretty_generate(result)
      else
        if entries.empty?
          puts "No matching North Star evidence."
        else
          puts format("%-28s %-32s %-16s %s", "ID", "TITLE", "TAGS", "REFERENCE")
          entries.each do |entry|
            puts format("%-28s %-32s %-16s %s", entry["id"], entry["title"][0, 32], Array(entry["tags"]).join(","), entry["reference"])
          end
        end
      end
      0
    end

    def command_sprint
      subcommand = @argv.shift
      case subcommand
      when "init" then command_sprint_init
      when "receipt" then command_sprint_receipt
      else
        raise UsageError, "Usage: bin/verdify sprint <init|receipt>"
      end
    end

    def command_sprint_init
      options = { repo: Dir.pwd, id: nil, milestone: nil, force: false }
      parser = OptionParser.new do |o|
        o.banner = "Usage: bin/verdify sprint init --id SPRINT-ID [--repo PATH] [--milestone NAME] [--force]"
        o.on("--repo PATH", "Target Git repository") { |v| options[:repo] = v }
        o.on("--id ID", "Sprint ID") { |v| options[:id] = v }
        o.on("--milestone NAME", "GitHub milestone name") { |v| options[:milestone] = v }
        o.on("--force", "Replace an existing draft skeleton") { options[:force] = true }
        o.on("-h", "--help") { puts o; return 0 }
      end
      parse_options(parser)
      raise UsageError, "--id is required" unless options[:id]
      raise UsageError, "invalid sprint ID" unless options[:id].match?(/\A[a-z0-9][a-z0-9-]*\z/)

      repo = GitRepository.new(options[:repo])
      sprint_dir = repo.root.join(".agent-workflow/sprints", options[:id])
      plan_path = sprint_dir.join("sprint-plan.yaml")
      if plan_path.exist? && !options[:force]
        raise UsageError, "sprint already exists: #{plan_path}"
      end

      %w[lanes/contracts lanes/closeout critic evidence release outcome gates prompts].each do |relative|
        FileUtils.mkdir_p(sprint_dir.join(relative))
      end

      plan = {
        "schema_ref" => "sprint-plan.schema.yaml",
        "kind" => "SprintPlan",
        "schema_version" => "1.0",
        "sprint_id" => options[:id],
        "status" => "draft",
        "goal" => "TBD during sprint-planning",
        "baseline_sha" => repo.head_sha,
        "github" => {
          "repository" => repo.github_slug || "local/#{repo.root.basename}",
          "milestone" => options[:milestone],
          "project" => nil
        },
        "issue_ids" => [],
        "scope" => [],
        "non_goals" => [],
        "acceptance_criteria" => [],
        "risks" => [],
        "lanes" => [],
        "dependency_order" => [],
        "deployment_expectations" => [],
        "review_plan" => {
          "qa_milestones" => [],
          "human_review_milestones" => [],
          "user_stories_for_review" => [],
          "reporting_summary" => {
            "included" => [],
            "deferred" => [],
            "ownership" => [],
            "next_review" => ""
          }
        },
        "approval" => { "status" => "pending", "approver" => nil, "approved_at" => nil }
      }
      gate = {
        "schema_ref" => "human-gate.schema.yaml",
        "kind" => "HumanGate",
        "schema_version" => "1.0",
        "gate_id" => "plan-approval-#{options[:id]}",
        "sprint_id" => options[:id],
        "lane_id" => nil,
        "type" => "plan_approval",
        "status" => "open",
        "question" => "Approve the completed sprint plan, lane topology, contracts, risks, and exceptions?",
        "owner" => "delivery-owner",
        "evidence_required" => ["sprint plan", "lane map", "lane contracts", "risk review"],
        "allowed_decisions" => %w[approve revise reject],
        "decision" => nil,
        "rationale" => nil,
        "opened_at" => Verdify.utc_now,
        "resolved_at" => nil,
        "resume_state" => "READY"
      }
      status = {
        "schema_ref" => "status.schema.yaml",
        "kind" => "SprintStatus",
        "schema_version" => "1.0",
        "sprint_id" => options[:id],
        "state" => "PLANNING",
        "updated_at" => Verdify.utc_now,
        "active_lanes" => [],
        "blockers" => [],
        "next_action" => "Run sprint-planning and complete the plan transaction."
      }

      Verdify.atomic_write(plan_path, YAML.dump(plan))
      Verdify.atomic_write(sprint_dir.join("gates/plan-approval.yaml"), YAML.dump(gate))
      Verdify.atomic_write(sprint_dir.join("status.yaml"), YAML.dump(status))
      puts "Initialized sprint #{options[:id]} at #{sprint_dir}"
      0
    end

    def command_sprint_receipt
      options = {
        repo: Dir.pwd,
        sprint: nil,
        controller_ref: nil,
        base: nil,
        mode: "normal",
        generator: "verdify-controller",
        json: false
      }
      parser = OptionParser.new do |o|
        o.banner = "Usage: bin/verdify sprint receipt --sprint ID --controller-ref REF --base SHA [options]"
        o.on("--repo PATH", "Receipt worktree") { |v| options[:repo] = v }
        o.on("--sprint ID", "Sprint transaction to terminalize") { |v| options[:sprint] = v }
        o.on("--controller-ref REF", "Pushed controller/<sprint-id> evidence ref") { |v| options[:controller_ref] = v }
        o.on("--base SHA", "Exact protected dev head used to create the receipt branch") { |v| options[:base] = v }
        o.on("--mode MODE", %w[normal recovery], "Normal one-sprint receipt or bounded issue-135 recovery") { |v| options[:mode] = v }
        o.on("--generator ID", "Controller identity recorded in the receipt") { |v| options[:generator] = v }
        o.on("--json", "Emit generated receipt JSON") { options[:json] = true }
        o.on("-h", "--help") { puts o; return 0 }
      end
      parse_options(parser)
      %i[sprint controller_ref base].each do |key|
        raise UsageError, "--#{key.to_s.tr('_', '-')} is required" if options[key].to_s.empty?
      end

      repo = GitRepository.new(options[:repo])
      receipt = SprintTerminalReceipt.new(repo: repo).write!(
        sprint_id: options[:sprint],
        controller_ref: options[:controller_ref],
        receipt_base_sha: options[:base],
        mode: options[:mode],
        generator: options[:generator]
      )
      if options[:json]
        puts JSON.pretty_generate(receipt)
      else
        paths = SprintTerminalReceipt.paths(options[:sprint])
        puts "Generated #{options[:mode]} terminal receipt for #{options[:sprint]}"
        puts "Receipt: #{paths.fetch(:receipt)}"
        puts "Branch: receipt/#{options[:mode] == 'recovery' ? SprintTerminalReceipt::RECOVERY_BUNDLE : options[:sprint]}/#{options[:base][0, 12]}"
      end
      0
    end

    def command_lane
      subcommand = @argv.shift
      case subcommand
      when "create" then command_lane_create
      when "review" then command_lane_review
      when "list" then command_lane_list
      when "inspect" then command_lane_inspect
      when "release" then command_lane_release
      else
        raise UsageError, "Usage: bin/verdify lane <create|review|list|inspect|release>"
      end
    end

    def command_lane_create
      options = {
        repo: Dir.pwd, sprint: nil, lane_id: nil, issue: nil, session_id: nil,
        agent: nil, base: nil, path: nil, contract: nil, dry_run: false,
        allow_stale_baseline: false
      }
      parser = OptionParser.new do |o|
        o.banner = "Usage: bin/verdify lane create --sprint ID --lane-id ID --issue N --session-id ID --agent NAME [options]"
        o.on("--repo PATH") { |v| options[:repo] = v }
        o.on("--sprint ID") { |v| options[:sprint] = v }
        o.on("--lane-id ID") { |v| options[:lane_id] = v }
        o.on("--issue N", Integer) { |v| options[:issue] = v }
        o.on("--session-id ID") { |v| options[:session_id] = v }
        o.on("--agent NAME") { |v| options[:agent] = v }
        o.on("--base REF", "Override baseline ref; must match contract unless allowed") { |v| options[:base] = v }
        o.on("--path PATH", "Worktree path") { |v| options[:path] = v }
        o.on("--contract PATH", "Lane contract path") { |v| options[:contract] = v }
        o.on("--allow-stale-baseline") { options[:allow_stale_baseline] = true }
        o.on("--dry-run") { options[:dry_run] = true }
        o.on("-h", "--help") { puts o; return 0 }
      end
      parse_options(parser)
      %i[sprint lane_id issue session_id agent].each do |key|
        raise UsageError, "--#{key.to_s.tr('_', '-')} is required" if options[key].nil? || options[key].to_s.empty?
      end

      repo = GitRepository.new(options[:repo])
      contract_path = resolve_contract_path(repo, options[:sprint], options[:lane_id], options[:contract])
      contract = load_and_validate_contract(contract_path)
      enforce_lane_contract!(contract, options)
      dispatch_artifacts = load_lane_dispatch_artifacts(contract_path, contract)

      base_ref = options[:base] || contract["baseline_sha"]
      resolved_base = repo.head_sha(base_ref)
      unless options[:allow_stale_baseline] || resolved_base == contract["baseline_sha"]
        raise UsageError, "resolved base #{resolved_base} does not match contract baseline #{contract['baseline_sha']}"
      end

      branch = contract["branch"]
      path = options[:path] ? Pathname.new(options[:path]).expand_path : default_worktree_path(repo, options[:lane_id])

      lease = build_lease(
        repo: repo,
        lease_id: options[:lane_id],
        sprint_id: options[:sprint],
        lane_id: options[:lane_id],
        issue_ids: contract["issue_ids"],
        role: "worker",
        agent: options[:agent],
        session_id: options[:session_id],
        branch: branch,
        baseline_sha: resolved_base,
        contract_path: contract_path,
        worktree_path: path,
        ttl_hours: contract.dig("lease_policy", "worker_ttl_hours") || 24
      )

      if options[:dry_run]
        with_lease_lock(repo) do
          expire_stale_leases!(repo)
          conflict = active_worker_lease(repo, options[:lane_id])
          raise UsageError, "lane already has active worker lease #{conflict['lease_id']}" if conflict
          raise UsageError, "worktree path already exists: #{path}" if path.exist?
        end

        puts "DRY RUN"
        puts "git worktree add #{repo.branch_exists?(branch) ? '' : "-b #{branch} "}#{path} #{repo.branch_exists?(branch) ? branch : resolved_base}".strip
        puts "seed approved sprint plan, wave release plan, and lane contract as one dispatch commit"
        puts "git worktree lock --reason #{Shellwords.escape("Verdify worker #{options[:lane_id]} session #{options[:session_id]}")} #{path}"
        puts JSON.pretty_generate(lease)
        return 0
      end

      with_lease_lock(repo) do
        expire_stale_leases!(repo)
        conflict = active_worker_lease(repo, options[:lane_id])
        raise UsageError, "lane already has active worker lease #{conflict['lease_id']}" if conflict
        raise UsageError, "worktree path already exists: #{path}" if path.exist?

        repo.add_worktree(path: path, branch: branch, base: resolved_base)
        begin
          seed_lane_dispatch_artifacts(path, dispatch_artifacts, contract["lane_id"])
          repo.lock_worktree(path, "Verdify worker #{options[:lane_id]} session #{options[:session_id]}")
          write_lease(repo, lease)
        rescue StandardError
          repo.unlock_worktree(path)
          repo.remove_worktree(path, force: true) if path.exist?
          raise
        end
      end

      print_lease_summary(lease)
      0
    end

    def command_lane_review
      options = { repo: Dir.pwd, lane_id: nil, session_id: nil, agent: nil, path: nil }
      parser = OptionParser.new do |o|
        o.banner = "Usage: bin/verdify lane review --lane-id ID --session-id ID --agent NAME [--repo PATH] [--path PATH]"
        o.on("--repo PATH") { |v| options[:repo] = v }
        o.on("--lane-id ID") { |v| options[:lane_id] = v }
        o.on("--session-id ID") { |v| options[:session_id] = v }
        o.on("--agent NAME") { |v| options[:agent] = v }
        o.on("--path PATH") { |v| options[:path] = v }
        o.on("-h", "--help") { puts o; return 0 }
      end
      parse_options(parser)
      %i[lane_id session_id agent].each do |key|
        raise UsageError, "--#{key.to_s.tr('_', '-')} is required" if options[key].to_s.empty?
      end

      repo = GitRepository.new(options[:repo])
      worker_lease = all_leases(repo).select { |l| l["lane_id"] == options[:lane_id] && l["role"] == "worker" }
                                     .max_by { |l| l["created_at"].to_s }
      contract_source_path = if worker_lease && Pathname.new(worker_lease["contract_path"]).file?
                               Pathname.new(worker_lease["contract_path"])
                             else
                               find_contract_by_lane(repo, options[:lane_id])
                             end
      if worker_lease && Pathname.new(worker_lease["contract_path"]).file? &&
         Digest::SHA256.file(contract_source_path).hexdigest != worker_lease["contract_hash"]
        raise UsageError, "worker lease contract hash no longer matches its contract"
      end
      contract_source_repo = GitRepository.new(contract_source_path.dirname)
      contract_relative_path = contract_source_path.relative_path_from(contract_source_repo.root)
      contract = load_and_validate_contract(contract_source_path)
      branch = contract["branch"]
      branch_head = repo.github_slug ? nil : repo.head_sha(branch)
      sprint_root = contract_relative_path.dirname.parent.parent
      closeout_relative_path = sprint_root.join("lanes/closeout/#{contract['lane_id']}.closeout.yaml")
      review_head = branch_head
      expected_pull_request = nil
      if repo.github_slug
        pull_request = repo.github_pull_request_for_branch(branch)
        expected_pull_request = pull_request["number"]
        fetched_head = repo.fetch_pull_request_head(expected_pull_request)
        unless fetched_head == pull_request["head_sha"]
          raise UsageError, "fetched pull request head does not match GitHub head"
        end
        review_head = fetched_head
      end
      begin
        closeout = YAML.safe_load(repo.file_at(review_head, closeout_relative_path), permitted_classes: [], aliases: false) || {}
      rescue Psych::Exception, CommandError => e
        raise UsageError, "lane closeout is not committed on the live review head: #{e.message}"
      end
      if closeout["worker_session_id"].to_s.empty?
        raise UsageError, "lane closeout does not record worker_session_id"
      end
      if worker_lease && closeout["worker_session_id"] != worker_lease["session_id"]
        raise UsageError, "lane closeout worker_session_id does not match worker lease history"
      end
      if worker_lease && closeout["worker_agent"] != worker_lease["agent"]
        raise UsageError, "lane closeout worker_agent does not match worker lease history"
      end
      if closeout["worker_session_id"] == options[:session_id]
        raise UsageError, "critic session must differ from worker session"
      end
      if closeout["worker_agent"] == options[:agent]
        raise UsageError, "critic agent must differ from worker agent"
      end
      if expected_pull_request && closeout["pull_request"] != expected_pull_request
        raise UsageError, "lane closeout pull_request does not match the live branch pull request"
      end

      lease_id = "critic-#{options[:lane_id]}-#{Verdify.slug(options[:session_id], max: 24)}"
      path = options[:path] ? Pathname.new(options[:path]).expand_path : default_review_path(repo, options[:lane_id], options[:session_id])

      lease = nil

      with_lease_lock(repo) do
        existing = lease_path(repo, lease_id)
        raise UsageError, "critic lease already exists: #{lease_id}" if existing.exist? && load_json(existing)["status"] == "active"
        raise UsageError, "review worktree path already exists: #{path}" if path.exist?

        repo.add_worktree(path: path, branch: branch, base: review_head, detach: true)
        begin
          review_repo = GitRepository.new(path)
          review_contract_path = path.join(contract_relative_path)
          review_closeout_path = path.join(closeout_relative_path)
          validation = LaneReviewValidator.new(
            repo: review_repo,
            contract_path: review_contract_path,
            closeout_path: review_closeout_path
          ).validate_closeout(evidence_head_sha: review_head)
          unless validation.valid?
            raise UsageError, "lane evidence is not reviewable:\n#{validation.errors.join("\n")}"
          end
          lease = build_lease(
            repo: repo,
            lease_id: lease_id,
            sprint_id: contract["sprint_id"],
            lane_id: contract["lane_id"],
            issue_ids: contract["issue_ids"],
            role: "critic",
            agent: options[:agent],
            session_id: options[:session_id],
            branch: branch,
            baseline_sha: review_head,
            contract_path: review_contract_path,
            worktree_path: path,
            ttl_hours: contract.dig("lease_policy", "critic_ttl_hours") || 8
          )
          repo.lock_worktree(path, "Verdify critic #{options[:lane_id]} session #{options[:session_id]}")
          write_lease(repo, lease)
        rescue StandardError
          repo.unlock_worktree(path)
          repo.remove_worktree(path, force: true) if path.exist?
          raise
        end
      end

      print_lease_summary(lease)
      0
    end

    def command_lane_list
      options = { repo: Dir.pwd, json: false }
      parser = OptionParser.new do |o|
        o.banner = "Usage: bin/verdify lane list [--repo PATH] [--json]"
        o.on("--repo PATH") { |v| options[:repo] = v }
        o.on("--json") { options[:json] = true }
        o.on("-h", "--help") { puts o; return 0 }
      end
      parse_options(parser)
      repo = GitRepository.new(options[:repo])
      expire_stale_leases!(repo)
      leases = all_leases(repo)
      if options[:json]
        puts JSON.pretty_generate({ "leases" => leases, "worktrees" => repo.worktrees })
      else
        if leases.empty?
          puts "No Verdify leases."
        else
          puts format("%-32s %-8s %-10s %-20s %s", "LEASE", "ROLE", "STATUS", "LANE", "WORKTREE")
          leases.each do |lease|
            puts format("%-32s %-8s %-10s %-20s %s", lease["lease_id"], lease["role"], lease["status"], lease["lane_id"], lease["worktree_path"])
          end
        end
      end
      0
    end

    def command_lane_inspect
      options = { repo: Dir.pwd, lease_id: nil }
      parser = OptionParser.new do |o|
        o.banner = "Usage: bin/verdify lane inspect --lease-id ID [--repo PATH]"
        o.on("--repo PATH") { |v| options[:repo] = v }
        o.on("--lease-id ID") { |v| options[:lease_id] = v }
        o.on("-h", "--help") { puts o; return 0 }
      end
      parse_options(parser)
      raise UsageError, "--lease-id is required" if options[:lease_id].to_s.empty?
      repo = GitRepository.new(options[:repo])
      path = lease_path(repo, options[:lease_id])
      raise UsageError, "lease not found: #{options[:lease_id]}" unless path.file?
      lease = load_json(path)
      worktree = Pathname.new(lease["worktree_path"])
      inspection = lease.merge("lease_file" => path.to_s, "worktree_exists" => worktree.directory?)
      if worktree.directory?
        stdout, stderr, status = Open3.capture3("git", "-C", worktree.to_s, "status", "--porcelain=v1", "--branch")
        inspection["git_status"] = status.success? ? stdout.lines.map(&:chomp) : [stderr.strip]
      end
      puts JSON.pretty_generate(inspection)
      0
    end

    def command_lane_release
      options = { repo: Dir.pwd, lease_id: nil, session_id: nil, remove: true, force: false }
      parser = OptionParser.new do |o|
        o.banner = "Usage: bin/verdify lane release --lease-id ID --session-id ID [--repo PATH] [--keep-worktree] [--force]"
        o.on("--repo PATH") { |v| options[:repo] = v }
        o.on("--lease-id ID") { |v| options[:lease_id] = v }
        o.on("--session-id ID") { |v| options[:session_id] = v }
        o.on("--keep-worktree", "Keep the locked worktree for manual recovery") { options[:remove] = false }
        o.on("--force", "Remove a dirty worktree") { options[:force] = true }
        o.on("-h", "--help") { puts o; return 0 }
      end
      parse_options(parser)
      %i[lease_id session_id].each do |key|
        raise UsageError, "--#{key.to_s.tr('_', '-')} is required" if options[key].to_s.empty?
      end
      repo = GitRepository.new(options[:repo])
      file = lease_path(repo, options[:lease_id])
      raise UsageError, "lease not found: #{options[:lease_id]}" unless file.file?
      lease = load_json(file)
      raise UsageError, "session ID does not own this lease" unless lease["session_id"] == options[:session_id]
      if lease["status"] == "released"
        puts "Lease #{options[:lease_id]} is already released."
        return 0
      end

      worktree = Pathname.new(lease["worktree_path"])
      if options[:remove] && worktree.directory?
        unless options[:force] || repo.clean?(worktree)
          raise UsageError, "worktree is dirty; commit/stash intended work or pass --force"
        end
        repo.unlock_worktree(worktree)
        repo.remove_worktree(worktree, force: options[:force])
      end

      lease["status"] = "released"
      lease["released_at"] = Verdify.utc_now
      write_lease(repo, lease)
      puts "Released #{lease['lease_id']}#{options[:remove] ? ' and removed its worktree' : '; worktree remains locked for recovery'}"
      0
    end

    def command_prompt
      subcommand = @argv.shift
      raise UsageError, "Usage: bin/verdify prompt compile --contract PATH --role worker|critic" unless subcommand == "compile"

      options = { repo: Dir.pwd, contract: nil, role: "worker", out: nil }
      parser = OptionParser.new do |o|
        o.banner = "Usage: bin/verdify prompt compile --contract PATH [--role worker|critic] [--repo PATH] [--out PATH]"
        o.on("--repo PATH") { |v| options[:repo] = v }
        o.on("--contract PATH") { |v| options[:contract] = v }
        o.on("--role ROLE", %w[worker critic]) { |v| options[:role] = v }
        o.on("--out PATH") { |v| options[:out] = v }
        o.on("-h", "--help") { puts o; return 0 }
      end
      parse_options(parser)
      raise UsageError, "--contract is required" unless options[:contract]
      repo = GitRepository.new(options[:repo])
      contract_path = resolve_repo_path(repo, options[:contract])
      contract = load_and_validate_contract(contract_path)

      skill_name = options[:role] == "worker" ? "lane-delivery" : "independent-critic"
      common_path = Verdify::ROOT.join("COMMON_OPERATING_CONTRACT.md")
      skill_path = Verdify::ROOT.join("skills", skill_name, "SKILL.md")
      common = common_path.read
      skill = strip_frontmatter(skill_path.read)
      contract_text = contract_path.read
      generated_at = Verdify.utc_now
      hashes = {
        "common_operating_contract" => Digest::SHA256.hexdigest(common),
        "role_skill" => Digest::SHA256.hexdigest(skill_path.read),
        "lane_contract" => Digest::SHA256.hexdigest(contract_text)
      }
      prompt = <<~PROMPT
        # Verdify #{options[:role]} prompt

        Generated: #{generated_at}
        Sprint: #{contract['sprint_id']}
        Lane: #{contract['lane_id']}
        Role: #{options[:role]}
        Contract SHA-256: #{hashes['lane_contract']}

        Work only from the durable inputs below. Do not rely on hidden context from another session.

        ## Common operating contract

        #{common}

        ## Role procedure

        #{skill}

        ## Authoritative lane contract

        ```yaml
        #{contract_text.rstrip}
        ```
      PROMPT

      out = options[:out] ? resolve_repo_path(repo, options[:out]) : contract_path.dirname.join("#{options[:role]}-prompt.md")
      manifest_path = out.sub_ext(".manifest.json")
      manifest = {
        "schema_ref" => "compiled-prompt-manifest.schema.yaml",
        "kind" => "CompiledPromptManifest",
        "schema_version" => "1.0",
        "generated_at" => generated_at,
        "role" => options[:role],
        "sprint_id" => contract["sprint_id"],
        "lane_id" => contract["lane_id"],
        "output" => out.to_s,
        "inputs" => {
          "common_operating_contract" => common_path.to_s,
          "role_skill" => skill_path.to_s,
          "lane_contract" => contract_path.to_s
        },
        "sha256" => hashes
      }
      validate_hash!(manifest, "compiled-prompt-manifest.schema.yaml", "compiled prompt manifest")
      Verdify.atomic_write(out, prompt)
      Verdify.atomic_write(manifest_path, JSON.pretty_generate(manifest) + "\n")
      puts "Compiled #{options[:role]} prompt: #{out}"
      puts "Manifest: #{manifest_path}"
      0
    end

    def command_github
      subcommand = @argv.shift
      case subcommand
      when "bootstrap" then command_github_bootstrap
      when "snapshot" then command_github_snapshot
      when "reconcile" then command_github_reconcile
      else
        raise UsageError, "Usage: bin/verdify github <bootstrap|snapshot|reconcile>"
      end
    end

    def command_github_bootstrap
      options = { repo: nil, apply: false }
      parser = OptionParser.new do |o|
        o.banner = "Usage: bin/verdify github bootstrap --repo OWNER/REPO [--apply]"
        o.on("--repo OWNER/REPO") { |v| options[:repo] = v }
        o.on("--apply", "Create or update labels via GitHub CLI") { options[:apply] = true }
        o.on("-h", "--help") { puts o; return 0 }
      end
      parse_options(parser)
      raise UsageError, "--repo is required" if options[:repo].to_s.empty?
      config = Verdify.safe_load_yaml(Verdify::ROOT.join("config/github-primitives.yaml"))
      labels = Array(config["labels"])
      if options[:apply] && !command_available?("gh")
        raise UsageError, "GitHub CLI (gh) is required with --apply"
      end
      labels.each do |label|
        command = ["gh", "label", "create", label["name"], "--repo", options[:repo], "--color", label["color"], "--description", label["description"], "--force"]
        if options[:apply]
          capture_external(*command)
          puts "applied #{label['name']}"
        else
          puts command.shelljoin
        end
      end
      unless options[:apply]
        puts "\nPreview only. Re-run with --apply to change GitHub."
      end
      puts "Project fields and branch/environment rules remain repository or organization administrator setup; see docs/github-operating-model.md."
      0
    end

    def command_github_snapshot
      options = { repo: nil, target: Dir.pwd, out: nil }
      parser = OptionParser.new do |o|
        o.banner = "Usage: bin/verdify github snapshot --repo OWNER/REPO [--target PATH] [--out PATH]"
        o.on("--repo OWNER/REPO") { |v| options[:repo] = v }
        o.on("--target PATH", "Target project repository") { |v| options[:target] = v }
        o.on("--out PATH", "Snapshot output path") { |v| options[:out] = v }
        o.on("-h", "--help") { puts o; return 0 }
      end
      parse_options(parser)
      raise UsageError, "--repo is required" if options[:repo].to_s.empty?
      raise UsageError, "GitHub CLI (gh) is required" unless command_available?("gh")

      target = Pathname.new(options[:target]).expand_path
      default_branch = capture_external("gh", "repo", "view", options[:repo], "--json", "defaultBranchRef", "--jq", ".defaultBranchRef.name").strip
      issues = JSON.parse(capture_external("gh", "issue", "list", "--repo", options[:repo], "--state", "all", "--limit", "500", "--json", "number,title,state,url,labels,milestone,assignees,createdAt,updatedAt"))
      prs = JSON.parse(capture_external("gh", "pr", "list", "--repo", options[:repo], "--state", "all", "--limit", "500", "--json", "number,title,state,url,isDraft,headRefName,baseRefName,labels,createdAt,updatedAt,mergedAt,body"))
      snapshot = {
        "schema_ref" => "github-snapshot.schema.yaml",
        "kind" => "GitHubSnapshot",
        "schema_version" => "1.0",
        "repository" => options[:repo],
        "captured_at" => Verdify.utc_now,
        "default_branch" => default_branch,
        "issues" => issues,
        "pull_requests" => prs
      }
      validate_hash!(snapshot, "github-snapshot.schema.yaml", "GitHub snapshot")
      out = options[:out] ? Pathname.new(options[:out]).expand_path : target.join(".agent-workflow/github/snapshot.json")
      Verdify.atomic_write(out, JSON.pretty_generate(snapshot) + "\n")
      puts "Wrote #{out} (#{issues.length} issues, #{prs.length} pull requests)"
      0
    rescue JSON::ParserError => e
      raise CommandError, "Could not parse GitHub CLI output: #{e.message}"
    end

    def command_github_reconcile
      options = { repo_path: Dir.pwd, sprint: nil, snapshot: nil }
      parser = OptionParser.new do |o|
        o.banner = "Usage: bin/verdify github reconcile --sprint ID [--repo-path PATH] [--snapshot PATH]"
        o.on("--repo-path PATH", "Target project repository") { |v| options[:repo_path] = v }
        o.on("--sprint ID") { |v| options[:sprint] = v }
        o.on("--snapshot PATH") { |v| options[:snapshot] = v }
        o.on("-h", "--help") { puts o; return 0 }
      end
      parse_options(parser)
      raise UsageError, "--sprint is required" if options[:sprint].to_s.empty?
      repo = GitRepository.new(options[:repo_path])
      snapshot_path = options[:snapshot] ? resolve_repo_path(repo, options[:snapshot]) : repo.root.join(".agent-workflow/github/snapshot.json")
      raise UsageError, "GitHub snapshot not found: #{snapshot_path}" unless snapshot_path.file?
      snapshot = load_json(snapshot_path)
      contracts = Dir[repo.root.join(".agent-workflow/sprints", options[:sprint], "lanes/contracts/*.yaml")].sort.map do |path|
        [Pathname.new(path), load_and_validate_contract(Pathname.new(path))]
      end
      raise UsageError, "no lane contracts found for sprint #{options[:sprint]}" if contracts.empty?

      issues_by_number = Array(snapshot["issues"]).to_h { |issue| [issue["number"].to_i, issue] }
      prs_by_branch = Array(snapshot["pull_requests"]).group_by { |pr| pr["headRefName"] }
      assignments = Hash.new { |h, k| h[k] = [] }
      errors = []
      warnings = []
      lanes = []

      contracts.each do |path, contract|
        lane_id = contract["lane_id"]
        issue_ids = contract["issue_ids"].map(&:to_i)
        issue_ids.each { |issue| assignments[issue] << lane_id }
        if issue_ids.length > 1 && contract["coupling_justification"].to_s.strip.empty?
          errors << "#{lane_id}: multi-issue lane lacks coupling_justification"
        end
        issue_ids.each do |issue|
          errors << "#{lane_id}: issue ##{issue} is absent from snapshot" unless issues_by_number.key?(issue)
        end
        prs = prs_by_branch[contract["branch"]] || []
        if prs.empty?
          warnings << "#{lane_id}: no pull request found for branch #{contract['branch']}"
        else
          body = prs.max_by { |pr| pr["updatedAt"].to_s }["body"].to_s
          issue_ids.each do |issue|
            pattern = /\b(?:close[sd]?|fix(?:e[sd])?|resolve[sd]?)\s*:?\s*##{issue}\b/i
            warnings << "#{lane_id}: PR body does not contain a closing link for ##{issue}" unless body.match?(pattern)
          end
        end
        lanes << {
          "lane_id" => lane_id,
          "contract" => path.relative_path_from(repo.root).to_s,
          "issue_ids" => issue_ids,
          "branch" => contract["branch"],
          "pull_requests" => prs.map { |pr| pr["number"] }
        }
      end

      assignments.each do |issue, lane_ids|
        errors << "issue ##{issue} is assigned to multiple lanes: #{lane_ids.join(', ')}" if lane_ids.uniq.length > 1
      end

      report = {
        "schema_ref" => "github-reconciliation.schema.yaml",
        "kind" => "GitHubReconciliation",
        "schema_version" => "1.0",
        "sprint_id" => options[:sprint],
        "repository" => snapshot["repository"],
        "snapshot_captured_at" => snapshot["captured_at"],
        "reconciled_at" => Verdify.utc_now,
        "lanes" => lanes,
        "errors" => errors,
        "warnings" => warnings,
        "ok" => errors.empty?
      }
      validate_hash!(report, "github-reconciliation.schema.yaml", "GitHub reconciliation")
      out = repo.root.join(".agent-workflow/sprints", options[:sprint], "reconciliation.json")
      Verdify.atomic_write(out, JSON.pretty_generate(report) + "\n")
      puts JSON.pretty_generate(report)
      errors.empty? ? 0 : 1
    end

    def command_gate
      subcommand = @argv.shift
      raise UsageError, "Usage: bin/verdify gate compliance [--repo PATH] [--json] [--report PATH] [--strict] [--no-strict] [--snapshot PATH]" unless subcommand == "compliance"

      command_gate_compliance
    end

    def command_gate_compliance
      options = { repo: Dir.pwd, json: false, report: nil, strict: false, report_only: false, snapshot: nil }
      parser = OptionParser.new do |o|
        o.banner = "Usage: bin/verdify gate compliance [--repo PATH] [--json] [--report PATH] [--strict] [--no-strict] [--snapshot PATH]"
        o.on("--repo PATH", "Repository under assessment (default current directory)") { |v| options[:repo] = v }
        o.on("--json", "Emit the assessment JSON to stdout") { options[:json] = true }
        o.on("--report PATH", "Write the assessment to PATH (default .agent-workflow/compliance/assessment.json)") { |v| options[:report] = v }
        o.on("--strict", "Use the rigorous tighten-later tier: also require access_project_block and the canonical project-definition.yaml/architecture.yaml. Default is the relaxed-to-North-Star v1 tier (Jason 2026-06-25).") { options[:strict] = true }
        o.on("--no-strict", "Report-only: assess without setting a non-zero exit status when a required check fails") { options[:report_only] = true }
        o.on("--snapshot PATH", "Opt-in GitHub snapshot for the reconcile cross-check") { |v| options[:snapshot] = v }
        o.on("-h", "--help") { puts o; return 0 }
      end
      parse_options(parser)

      repo = GitRepository.new(options[:repo])
      assessment = ComplianceAssessor.new(repo: repo, strict: options[:strict], snapshot_path: options[:snapshot]).assess
      validate_hash!(assessment, "compliance-assessment.schema.yaml", "compliance assessment")

      report_path = options[:report] ? resolve_repo_path(repo, options[:report]) : repo.root.join(".agent-workflow/compliance/assessment.json")
      Verdify.atomic_write(report_path, JSON.pretty_generate(assessment) + "\n")

      if options[:json]
        puts JSON.pretty_generate(assessment)
      else
        assessment["checks"].each do |check|
          marker = check["status"] == "pass" ? "PASS" : (check["required"] ? "FAIL" : "WARN")
          puts format("%-4s %-24s %s", marker, check["id"], check["title"])
          check["details"].each { |detail| puts "       - #{detail}" }
        end
        summary = assessment["summary"]
        puts format("compliance %s (%d/%d checks passed, %d required failed)",
                    assessment["ok"] ? "OK" : "FAILED", summary["passed"], summary["total"], summary["required_failed"])
        puts "Report: #{report_path.relative_path_from(repo.root)}"
      end

      assessment["ok"] || options[:report_only] ? 0 : 1
    end

    def build_route_decision(repo, requested_sprint_id: nil)
      root = repo.root.join(".agent-workflow")
      evidence = []
      missing = []
      workflow_relative = root.relative_path_from(repo.root).to_s
      committed_gate_paths = repo.tracked_paths(ref: repo.head_sha, pathspec: workflow_relative).grep(%r{/gates/[^/]+\.yaml\z})
      working_gate_paths = Dir[root.join("**/gates/*.yaml")].map { |path| Pathname.new(path).relative_path_from(repo.root).to_s }.uniq.sort
      gate_snapshot_errors = (committed_gate_paths | working_gate_paths).filter_map do |relative|
        path = repo.root.join(relative)
        if !committed_gate_paths.include?(relative)
          "#{relative}: gate is uncommitted"
        elsif !path.file?
          "#{relative}: committed gate is deleted from the working tree"
        elsif repo.file_at(repo.head_sha, relative) != path.binread
          "#{relative}: working gate differs from HEAD"
        end
      end
      gate_documents = {}
      committed_gate_paths.each do |relative|
        path = repo.root.join(relative)
        next unless path.file?

        gate = Verdify.safe_load_yaml(path)
        errors = SchemaValidator.new.validate(gate, SchemaValidator.load_document(Verdify::ROOT.join("schemas/human-gate.schema.yaml")))
        errors.concat(SemanticValidator.validate(gate))
        gate_snapshot_errors.concat(errors.map { |error| "#{relative}: #{error}" })
        gate_documents[relative] = gate
      end
      unless gate_snapshot_errors.empty?
        evidence << { "source" => workflow_relative, "finding" => gate_snapshot_errors.join("; ") }
        return route_hash(repo, "GATE_STATE_UNCOMMITTED", "project-router", "route", "Durable gate state must be committed, present, and schema-valid before routing.", evidence, missing, [])
      end
      open_gates = gate_documents.filter_map { |relative, gate| relative if gate["status"] == "open" }
      open_gate_files = open_gates.map { |relative| repo.root.join(relative) }

      unless open_gate_files.empty?
        gate = gate_documents.fetch(open_gates.first)
        skill, mode = route_for_gate(gate["type"])
        evidence << { "source" => open_gates.first, "finding" => "open #{gate['type']} gate" }
        return route_hash(repo, "OPEN_GATE", skill, mode, "An open durable gate blocks normal progression.", evidence, missing, open_gates)
      end

      intake_route = route_for_pending_transcript_replan(repo, root, evidence, missing, open_gates)
      return intake_route if intake_route

      research_route = route_for_pending_northstar_research_ingest(repo, root, evidence, missing, open_gates)
      return research_route if research_route

      northstar_route = route_for_pending_northstar_plan(repo, root, evidence, missing, open_gates)
      return northstar_route if northstar_route

      project_path = root.join("project/project-definition.yaml")
      unless project_path.file?
        missing << project_path.relative_path_from(repo.root).to_s
        return route_hash(repo, "PROJECT_DEFINITION_MISSING", "project-definition", "discovery", "No canonical project definition exists.", evidence, missing, open_gates)
      end
      project = Verdify.safe_load_yaml(project_path)
      stage_order = [["discovery", "discovery"], ["requirements", "requirements"], ["product", "product"], ["design_surface", "design-surface"]]
      incomplete = stage_order.find { |key, _mode| project.dig("stage_status", key) != "approved" }
      if incomplete
        evidence << { "source" => project_path.relative_path_from(repo.root).to_s, "finding" => "stage_status.#{incomplete[0]} is #{project.dig('stage_status', incomplete[0]).inspect}" }
        return route_hash(repo, "PROJECT_DEFINITION_INCOMPLETE", "project-definition", incomplete[1], "The earliest project-definition mode is not approved.", evidence, missing, open_gates)
      end

      project_gate_path = root.join("gates/project-definition.yaml")
      unless project.dig("approval", "status") == "approved" || approved_gate?(project_gate_path, "project_definition")
        missing << project_gate_path.relative_path_from(repo.root).to_s
        evidence << { "source" => project_path.relative_path_from(repo.root).to_s, "finding" => "approval.status is #{project.dig('approval', 'status').inspect}" }
        return route_hash(repo, "PROJECT_DEFINITION_GATE", "project-definition", "design-surface", "Project-definition stages are approved, but human approval is not recorded.", evidence, missing, open_gates)
      end

      architecture_path = root.join("architecture/architecture.yaml")
      unless architecture_path.file? && Verdify.safe_load_yaml(architecture_path).dig("approval", "status") == "approved"
        missing << architecture_path.relative_path_from(repo.root).to_s
        return route_hash(repo, "ARCHITECTURE_INCOMPLETE", "architecture-contracts", "north-star-architecture", "Approved architecture is missing or incomplete.", evidence, missing, open_gates)
      end

      module_paths = Dir[root.join("modules/contracts/*.yaml")]
      if module_paths.empty? || module_paths.any? { |path| Verdify.safe_load_yaml(path).dig("approval", "status") != "approved" }
        missing << ".agent-workflow/modules/contracts/<module-id>.contract.yaml"
        return route_hash(repo, "MODULE_CONTRACTS_INCOMPLETE", "architecture-contracts", "module-contracts", "Approved black-box module contracts are missing or incomplete.", evidence, missing, open_gates)
      end

      sprint_root_relative = root.join("sprints").relative_path_from(repo.root).to_s
      transaction_path_pattern = %r{\A#{Regexp.escape(sprint_root_relative)}/[^/]+/(?:sprint-plan\.yaml|status\.yaml|lanes/contracts/[^/]+\.yaml|release/(?:wave-release-plan|release-verification)\.yaml|outcome/outcome-review\.yaml|terminal/terminal-receipt\.yaml|gates/cancellation\.yaml)\z}
      committed_transaction_paths = repo.tracked_paths(ref: repo.head_sha, pathspec: sprint_root_relative).grep(transaction_path_pattern)
      working_transaction_paths = [
        root.join("sprints/*/sprint-plan.yaml"),
        root.join("sprints/*/status.yaml"),
        root.join("sprints/*/lanes/contracts/*.yaml"),
        root.join("sprints/*/release/wave-release-plan.yaml"),
        root.join("sprints/*/release/release-verification.yaml"),
        root.join("sprints/*/outcome/outcome-review.yaml"),
        root.join("sprints/*/terminal/terminal-receipt.yaml"),
        root.join("sprints/*/gates/cancellation.yaml")
      ].flat_map { |pattern| Dir[pattern] }
       .map { |path| Pathname.new(path).relative_path_from(repo.root).to_s }
       .uniq
       .sort
      transaction_snapshot_errors = (committed_transaction_paths | working_transaction_paths).filter_map do |relative|
        path = repo.root.join(relative)
        if !committed_transaction_paths.include?(relative)
          "#{relative}: transaction artifact is uncommitted"
        elsif !path.file?
          "#{relative}: committed transaction artifact is deleted from the working tree"
        elsif repo.file_at(repo.head_sha, relative) != path.binread
          "#{relative}: working transaction artifact differs from HEAD"
        end
      end
      unless transaction_snapshot_errors.empty?
        evidence << { "source" => sprint_root_relative, "finding" => transaction_snapshot_errors.join("; ") }
        return route_hash(repo, "SPRINT_TRANSACTION_UNCOMMITTED", "sprint-planning", "lane-transaction", "Sprint selection and lane authority require an exact committed plan, status, and contract snapshot.", evidence, missing, open_gates)
      end

      plans = committed_transaction_paths.grep(%r{/sprint-plan\.yaml\z}).map { |path| repo.root.join(path) }.sort_by(&:to_s).reverse
      if plans.empty?
        strategy_route = route_for_strategy(repo, root, evidence, missing, open_gates)
        return strategy_route if strategy_route

        return strategy_handoff_route(repo, root, evidence, missing, open_gates)
      end

      plan_documents = {}
      status_documents = {}
      verified_terminal_plans = {}
      selection_errors = []
      plans.each do |path|
        plan = Verdify.safe_load_yaml(path)
        plan_documents[path] = plan
        expected_sprint_id = path.dirname.basename.to_s
        plan_validation = SchemaValidator.new.validate(plan, SchemaValidator.load_document(Verdify::ROOT.join("schemas/sprint-plan.schema.yaml")))
        plan_validation.concat(SemanticValidator.validate(plan))
        selection_errors.concat(plan_validation.map { |error| "#{path.relative_path_from(repo.root)}: #{error}" })
        unless plan["sprint_id"] == expected_sprint_id
          selection_errors << "#{path.relative_path_from(repo.root)}: sprint_id must match its sprint directory"
        end
        status_path = path.dirname.join("status.yaml")
        if status_path.file?
          status = Verdify.safe_load_yaml(status_path)
          status_documents[path] = status
          status_validation = SchemaValidator.new.validate(status, SchemaValidator.load_document(Verdify::ROOT.join("schemas/status.schema.yaml")))
          status_validation.concat(SemanticValidator.validate(status))
          selection_errors.concat(status_validation.map { |error| "#{status_path.relative_path_from(repo.root)}: #{error}" })
          unless status["sprint_id"] == expected_sprint_id && status["sprint_id"] == plan["sprint_id"]
            selection_errors << "#{status_path.relative_path_from(repo.root)}: sprint_id must match its sprint directory and plan"
          end
        end

        plan_terminal = %w[complete cancelled].include?(plan["status"].to_s.downcase)
        status_state = status_documents.dig(path, "state")
        status_terminal = %w[COMPLETE CANCELLED].include?(status_state)
        if plan_terminal || status_terminal
          plan_state = plan["status"].to_s.downcase
          expected_status_state = plan_state == "complete" ? "COMPLETE" : "CANCELLED"
          unless plan_terminal && status_terminal && status_state == expected_status_state
            selection_errors << "#{path.relative_path_from(repo.root)}: plan and status terminal states must agree"
            next
          end
          if plan_state == "cancelled"
            cancellation_path = path.dirname.join("gates/cancellation.yaml")
            unless cancellation_path.file?
              selection_errors << "#{path.relative_path_from(repo.root)}: cancelled sprint terminalization requires an approved cancellation gate"
              next
            end
            cancellation = Verdify.safe_load_yaml(cancellation_path)
            cancellation_errors = SchemaValidator.new.validate(cancellation, SchemaValidator.load_document(Verdify::ROOT.join("schemas/human-gate.schema.yaml")))
            cancellation_errors.concat(SemanticValidator.validate(cancellation))
            cancellation_errors << "cancellation gate sprint_id must match" unless cancellation["sprint_id"] == expected_sprint_id
            cancellation_errors << "cancellation gate must be an approved decision" unless cancellation["type"] == "decision" && cancellation["status"] == "approved" && cancellation["decision"].to_s.downcase == "cancel"
            selection_errors.concat(cancellation_errors.map { |error| "#{cancellation_path.relative_path_from(repo.root)}: #{error}" })
            verified_terminal_plans[path] = "cancelled" if cancellation_errors.empty?
            next
          end


          receipt_validator = SprintTerminalReceipt.new(repo: repo)
          if receipt_validator.receipt_required_for_terminal?(path.relative_path_from(repo.root).to_s, ref: repo.head_sha)
            unless receipt_validator.terminal_at?(expected_sprint_id, ref: repo.head_sha)
              selection_errors << "#{path.relative_path_from(repo.root)}: post-cutover COMPLETE requires a valid protected-dev terminal receipt"
              next
            end
          end

          delivery_evidence = validate_delivery_evidence(repo, path.dirname, expected_sprint_id)
          release = delivery_evidence["release"]
          outcome = delivery_evidence["outcome"]
          terminal_errors = delivery_evidence["errors"]
          if release && outcome
            terminal_errors << "release verification must be verified" unless release["status"] == "verified"
            terminal_errors << "outcome review must be accepted" unless %w[accepted accepted_with_risks].include?(outcome["decision"])
          else
            terminal_errors << "COMPLETE requires committed release verification and outcome review"
          end
          selection_errors.concat(terminal_errors.map { |error| "#{path.relative_path_from(repo.root)}: #{error}" })
          verified_terminal_plans[path] = "complete" if terminal_errors.empty?
        end
      end
      unless selection_errors.empty?
        evidence << { "source" => sprint_root_relative, "finding" => selection_errors.join("; ") }
        return route_hash(repo, "SPRINT_PLAN_INVALID", "sprint-planning", "lane-transaction", "Committed sprint plans and statuses must validate and agree with their directory identity before sprint selection.", evidence, missing, open_gates)
      end

      active_plans = plans.reject { |path| verified_terminal_plans.key?(path) }
      routeable_plans = active_plans
      if requested_sprint_id
        selected = active_plans.select { |path| plan_documents.fetch(path)["sprint_id"] == requested_sprint_id }
        if selected.empty?
          evidence << { "source" => sprint_root_relative, "finding" => "requested active sprint #{requested_sprint_id.inspect} was not found" }
          return route_hash(repo, "SPRINT_SELECTION_REQUIRED", "project-router", "route", "The requested sprint is not an active committed transaction.", evidence, missing, open_gates)
        end
        routeable_plans = selected
      end
      if routeable_plans.length > 1
        evidence << { "source" => sprint_root_relative, "finding" => "multiple active sprint plans: #{routeable_plans.map { |path| path.dirname.basename.to_s }.join(', ')}" }
        return route_hash(repo, "SPRINT_TRANSACTION_AMBIGUOUS", "project-router", "route", "Multiple committed sprint transactions are active; rerun route with --sprint ID.", evidence, missing, open_gates)
      end
      plan_path = routeable_plans.first
      unless plan_path
        strategy_route = route_for_strategy(repo, root, evidence, missing, open_gates)
        return strategy_route if strategy_route

        return strategy_handoff_route(repo, root, evidence, missing, open_gates)
      end

      plan = plan_documents.fetch(plan_path)
      sprint_id = plan["sprint_id"]
      evidence << { "source" => plan_path.relative_path_from(repo.root).to_s, "finding" => "active sprint #{sprint_id} has status #{plan['status']}" }
      plan_errors = SchemaValidator.new.validate(plan, SchemaValidator.load_document(Verdify::ROOT.join("schemas/sprint-plan.schema.yaml")))
      plan_errors.concat(SemanticValidator.validate(plan))
      unless plan_errors.empty?
        evidence << { "source" => plan_path.relative_path_from(repo.root).to_s, "finding" => plan_errors.join("; ") }
        return route_hash(repo, "SPRINT_PLAN_INVALID", "sprint-planning", "lane-transaction", "The committed sprint plan does not satisfy its schema and semantic contract.", evidence, missing, open_gates)
      end
      plan_relative_path = plan_path.relative_path_from(repo.root)
      plan_commit = repo.last_change_sha(plan_relative_path, ref: repo.head_sha)
      if plan_commit.nil? || repo.file_at(plan_commit, plan_relative_path) != plan_path.binread
        evidence << { "source" => plan_relative_path.to_s, "finding" => "sprint plan is uncommitted or differs from its committed snapshot" }
        return route_hash(repo, "SPRINT_PLAN_UNCOMMITTED", "sprint-planning", "lane-transaction", "The atomic sprint plan must be committed before routing can evaluate its lanes.", evidence, missing, open_gates)
      end
      unless plan.dig("approval", "status") == "approved"
        return route_hash(repo, "SPRINT_PLAN_UNAPPROVED", "sprint-planning", "plan-approval", "The complete sprint/lane transaction is not approved.", evidence, missing, open_gates)
      end

      contracts = Dir[plan_path.dirname.join("lanes/contracts/*.yaml")].map { |p| Pathname.new(p) }
      if contracts.empty?
        missing << ".agent-workflow/sprints/#{sprint_id}/lanes/contracts/<lane-id>.contract.yaml"
        return route_hash(repo, "LANE_TRANSACTION_INCOMPLETE", "sprint-planning", "lane-transaction", "The approved sprint has no lane contracts.", evidence, missing, open_gates)
      end

      planned_lanes = Array(plan["lanes"])
      contract_documents = contracts.to_h { |path| [path, Verdify.safe_load_yaml(path)] }
      planned_by_lane = planned_lanes.to_h { |lane| [lane["lane_id"], lane] }
      contracts_by_lane = contract_documents.to_h { |path, contract| [contract["lane_id"], [path, contract]] }
      transaction_errors = []
      contracts.each do |contract_path|
        relative = contract_path.relative_path_from(repo.root)
        commit = repo.last_change_sha(relative, ref: repo.head_sha)
        unless commit && repo.file_at(commit, relative) == contract_path.binread
          transaction_errors << "#{relative}: lane contract is uncommitted or differs from its committed snapshot"
        end
      end
      transaction_errors << "sprint plan contains duplicate lane IDs" unless planned_by_lane.length == planned_lanes.length
      transaction_errors << "lane contracts contain duplicate lane IDs" unless contracts_by_lane.length == contracts.length
      unless planned_by_lane.keys.sort == contracts_by_lane.keys.sort
        transaction_errors << "planned lane IDs must exactly match contract lane IDs"
      end
      contracts_by_lane.each do |lane_id, (contract_path, contract)|
        schema = SchemaValidator.load_document(Verdify::ROOT.join("schemas/lane-contract.schema.yaml"))
        validation_errors = SchemaValidator.new.validate(contract, schema) + SemanticValidator.validate(contract)
        transaction_errors.concat(validation_errors.map { |error| "#{lane_id}: #{error}" })
        unless %w[approved dispatched changes_requested].include?(contract["status"]) && contract.dig("approval", "status") == "approved"
          transaction_errors << "#{lane_id}: lane contract is not approved for execution"
        end
        transaction_errors << "#{lane_id}: lane contract sprint_id differs from the active sprint" unless contract["sprint_id"] == sprint_id
        planned_lane = planned_by_lane[lane_id]
        next unless planned_lane

        transaction_errors << "#{lane_id}: issue assignment differs between sprint plan and contract" unless Array(planned_lane["issue_ids"]) == Array(contract["issue_ids"])
        transaction_errors << "#{lane_id}: branch differs between sprint plan and contract" unless planned_lane["branch"] == contract["branch"]
        actual_contract_path = contract_path.relative_path_from(repo.root).to_s
        transaction_errors << "#{lane_id}: sprint plan contract_path does not identify the loaded contract" unless planned_lane["contract_path"] == actual_contract_path
      end
      unless transaction_errors.empty?
        evidence << { "source" => plan_path.relative_path_from(repo.root).to_s, "finding" => transaction_errors.join("; ") }
        return route_hash(repo, "LANE_TRANSACTION_INCOMPLETE", "sprint-planning", "lane-transaction", "The approved sprint and executable lane-contract set do not reconcile exactly.", evidence, missing, open_gates)
      end

      lane_review_results = {}
      contracts.each do |contract_path|
        contract = contract_documents.fetch(contract_path)
        lane_id = contract["lane_id"]
        closeout_path = plan_path.dirname.join("lanes/closeout/#{lane_id}.closeout.yaml")
        unless closeout_path.file?
          missing << closeout_path.relative_path_from(repo.root).to_s
          return route_hash(repo, "LANES_REQUIRE_ORCHESTRATION", "sprint-orchestrator", "platform-dispatch", "At least one approved lane has no worker closeout.", evidence, missing, open_gates)
        end
        critic_path = plan_path.dirname.join("critic/#{lane_id}.critic.yaml")
        branch_tip = repo.commit_exists?(contract["branch"]) ? repo.head_sha(contract["branch"]) : nil
        if repo.github_slug
          begin
            live_pull = repo.github_pull_request_for_branch(contract["branch"])
            fetched_head = repo.fetch_pull_request_head(live_pull["number"])
            evidence_document = Verdify.safe_load_yaml(critic_path.file? ? critic_path : closeout_path)
            unless fetched_head == live_pull["head_sha"] && live_pull["number"] == evidence_document["pull_request"]
              raise CommandError, "fetched lane PR head or number does not match the lane evidence"
            end
            branch_tip = fetched_head
          rescue CommandError => e
            source = critic_path.file? ? critic_path : closeout_path
            evidence << { "source" => source.relative_path_from(repo.root).to_s, "finding" => e.message }
            return route_hash(repo, "LANE_REVIEW_EVIDENCE_INVALID", "sprint-orchestrator", "gate-management", "The live lane PR head could not be fetched for evidence validation.", evidence, missing, open_gates)
          end
        end
        unless critic_path.file?
          lane_tip = branch_tip || repo.head_sha
          evidence_head = repo.last_change_sha(closeout_path.relative_path_from(repo.root), ref: lane_tip)
          validation = LaneReviewValidator.new(
            repo: repo,
            contract_path: contract_path,
            closeout_path: closeout_path
          ).validate_closeout(evidence_head_sha: evidence_head)
          unless validation.valid?
            evidence << { "source" => closeout_path.relative_path_from(repo.root).to_s, "finding" => validation.errors.join("; ") }
            return route_hash(repo, "LANE_CLOSEOUT_EVIDENCE_INVALID", "lane-delivery", "fix-forward", "The worker closeout or its implementation-to-evidence Git chain is invalid.", evidence, missing, open_gates)
          end
          missing << critic_path.relative_path_from(repo.root).to_s
          return route_hash(repo, "LANE_READY_FOR_CRITIC", "independent-critic", "lane-review", "A worker closeout awaits fresh independent review.", evidence, missing, open_gates)
        end
        review_validator = LaneReviewValidator.new(
          repo: repo,
          contract_path: contract_path,
          closeout_path: closeout_path,
          critic_path: critic_path
        )
        candidate_tips = [branch_tip, repo.head_sha].compact.uniq
        candidate_results = candidate_tips.map { |tip| review_validator.validate_critic(tip_sha: tip) }
        validation = candidate_results.find(&:valid?) || candidate_results.last
        unless validation.valid?
          evidence << { "source" => critic_path.relative_path_from(repo.root).to_s, "finding" => validation.errors.join("; ") }
          return route_hash(repo, "LANE_REVIEW_EVIDENCE_INVALID", "sprint-orchestrator", "gate-management", "The critic artifact or implementation/evidence/report Git chain is invalid and cannot advance.", evidence, missing, open_gates)
        end
        lane_review_results[lane_id] = validation
        critic = Verdify.safe_load_yaml(critic_path)
        unless %w[approve approve_with_risks].include?(critic["outcome"])
          return route_hash(repo, "CRITIC_ACTION_REQUIRED", "sprint-orchestrator", "gate-management", "A critic outcome requires fixes, blocking, or human review.", evidence, missing, open_gates)
        end
      end

      review_path = plan_path.dirname.join("review/review-inbox-packet.yaml")
      unless review_path.file?
        missing << review_path.relative_path_from(repo.root).to_s
        return route_hash(repo, "REVIEW_INBOX_REQUIRED", "release-verification", "review-inbox", "Lanes with approving critic outcomes need a review inbox packet before integration or human review.", evidence, missing, open_gates)
      end
      review = Verdify.safe_load_yaml(review_path)
      review_errors = SchemaValidator.new.validate(review, SchemaValidator.load_document(Verdify::ROOT.join("schemas/review-inbox-packet.schema.yaml")))
      review_errors.concat(SemanticValidator.validate(review))
      unless review_errors.empty?
        evidence << { "source" => review_path.relative_path_from(repo.root).to_s, "finding" => review_errors.join("; ") }
        return route_hash(repo, "REVIEW_INBOX_INCOMPLETE", "release-verification", "review-inbox", "The review inbox packet does not validate against the current evidence contract.", evidence, missing, open_gates)
      end
      review_relative_path = review_path.relative_path_from(repo.root)
      review_commit = repo.last_change_sha(review_relative_path, ref: repo.head_sha)
      packet_commit_is_atomic = review_commit &&
                                repo.commit_parents(review_commit).length == 1 &&
                                repo.changed_paths(review_commit) == [review_relative_path.to_s]
      packet_snapshot_valid = review_commit &&
                              repo.ancestor?(review_commit, repo.head_sha) &&
                              repo.file_at(review_commit, review_relative_path) == review_path.binread
      if review_commit.nil? || !packet_commit_is_atomic || !packet_snapshot_valid
        evidence << { "source" => review_relative_path.to_s, "finding" => "review packet is uncommitted, differs from its committed snapshot, is not on the controller history, or shares its commit with another path" }
        return route_hash(repo, "REVIEW_INBOX_INCOMPLETE", "release-verification", "review-inbox", "The review inbox packet must be the only changed path in its authoritative controller commit.", evidence, missing, open_gates)
      end
      release_verification_relative = plan_path.dirname.join("release/release-verification.yaml").relative_path_from(repo.root).to_s
      outcome_review_relative = plan_path.dirname.join("outcome/outcome-review.yaml").relative_path_from(repo.root).to_s
      status_relative = plan_path.dirname.join("status.yaml").relative_path_from(repo.root).to_s
      post_packet_allowed_paths = [release_verification_relative, outcome_review_relative, status_relative, plan_relative_path.to_s]
      post_packet_errors = []
      repo.commits_between(review_commit, repo.head_sha).each do |commit|
        post_packet_errors << "post-packet controller suffix contains merge commit #{commit}" unless repo.commit_parents(commit).length == 1
        paths = repo.changed_paths(commit)
        unauthorized = paths - post_packet_allowed_paths
        post_packet_errors << "post-packet controller commit #{commit} changes unauthorized paths: #{unauthorized.join(', ')}" unless unauthorized.empty?
        if paths.include?(plan_relative_path.to_s) && paths.sort != [plan_relative_path.to_s, status_relative].sort
          post_packet_errors << "sprint-plan terminalization must atomically change only sprint-plan.yaml and status.yaml"
        end
      end
      unless post_packet_errors.empty?
        evidence << { "source" => review_relative_path.to_s, "finding" => post_packet_errors.join("; ") }
        return route_hash(repo, "REVIEW_INBOX_INCOMPLETE", "release-verification", "review-inbox", "Only canonical release, outcome, status, and atomic terminalization artifacts may follow the review packet.", evidence, missing, open_gates)
      end
      controller_ref = review.dig("traceability", "head_ref")
      expected_controller_ref = "controller/#{Verdify.slug(sprint_id)}"
      current_branch = repo.current_branch
      lane_branches = contract_documents.values.map { |contract| contract["branch"] }
      remote_controller_head = begin
        current_branch.to_s.empty? ? nil : repo.remote_branch_sha(current_branch)
      rescue CommandError
        nil
      end
      unless !current_branch.to_s.empty? &&
             controller_ref == current_branch &&
             controller_ref == expected_controller_ref &&
             !lane_branches.include?(current_branch) &&
             remote_controller_head == repo.head_sha
        evidence << { "source" => review_relative_path.to_s, "finding" => "review packet controller ref is detached, lane-owned, unpushed, stale, or not the declared head_ref" }
        return route_hash(repo, "REVIEW_INBOX_INCOMPLETE", "release-verification", "review-inbox", "The review inbox packet must exist on a pushed authoritative controller branch separate from lane PR branches.", evidence, missing, open_gates)
      end
      controller_baseline = plan["baseline_sha"].to_s
      controller_allowed_paths = [
        plan_relative_path.to_s,
        review_relative_path.to_s,
        plan_path.dirname.join("release/wave-release-plan.yaml").relative_path_from(repo.root).to_s,
        release_verification_relative,
        outcome_review_relative,
        status_relative,
        *contracts.map { |path| path.relative_path_from(repo.root).to_s },
        *lane_review_results.keys.flat_map do |lane_id|
          [
            plan_path.dirname.join("lanes/closeout/#{lane_id}.closeout.yaml").relative_path_from(repo.root).to_s,
            plan_path.dirname.join("critic/#{lane_id}.critic.yaml").relative_path_from(repo.root).to_s
          ]
        end
      ].uniq.sort
      controller_history_errors = []
      unless controller_baseline.match?(/\A[0-9a-f]{40}\z/i) && repo.commit_exists?(controller_baseline) && repo.ancestor?(controller_baseline, repo.head_sha)
        controller_history_errors << "controller evidence branch must descend from the SprintPlan baseline_sha"
      else
        repo.commits_between(controller_baseline, repo.head_sha).each do |commit|
          controller_history_errors << "controller evidence branch contains merge commit #{commit}" unless repo.commit_parents(commit).length == 1
          unauthorized = repo.changed_paths(commit) - controller_allowed_paths
          unless unauthorized.empty?
            controller_history_errors << "controller evidence commit #{commit} changes unauthorized paths: #{unauthorized.join(', ')}"
          end
        end
      end
      lane_review_results.each do |lane_id, result|
        {
          plan_relative_path.to_s => plan_path,
          plan_path.dirname.join("release/wave-release-plan.yaml").relative_path_from(repo.root).to_s => plan_path.dirname.join("release/wave-release-plan.yaml")
        }.each do |relative, working_path|
          begin
            unless working_path.file? && repo.file_at(result.critic_report_head_sha, relative) == working_path.binread
              controller_history_errors << "#{lane_id}: controller #{relative} does not match the externally reviewed lane head"
            end
          rescue CommandError => e
            controller_history_errors << "#{lane_id}: could not verify #{relative} at the reviewed lane head: #{e.message}"
          end
        end
      end
      unless controller_history_errors.empty?
        evidence << { "source" => review_relative_path.to_s, "finding" => controller_history_errors.join("; ") }
        return route_hash(repo, "REVIEW_INBOX_INCOMPLETE", "release-verification", "review-inbox", "The controller branch is evidence-only: it must linearly copy the approved transaction and lane evidence without implementation changes.", evidence, missing, open_gates)
      end
      packet_scope_errors = []
      expected_lane_ids = lane_review_results.keys.sort
      expected_issue_ids = lane_review_results.values.flat_map { |result| result.closeout["issue_ids"] }.uniq.sort
      expected_pull_requests = lane_review_results.values.map { |result| result.critic["pull_request"] }.uniq.sort
      packet_scope_errors << "scope.sprint_id does not match active sprint" unless review.dig("scope", "sprint_id") == sprint_id
      packet_scope_errors << "scope.lane_ids do not match validated lanes" unless Array(review.dig("scope", "lane_ids")).sort == expected_lane_ids
      packet_scope_errors << "scope.issue_ids do not match validated lane issues" unless Array(review.dig("scope", "issue_ids")).sort == expected_issue_ids
      submission_pull_requests = Array(review.dig("traceability", "review_submissions")).map { |item| item["pull_request"] }.sort
      packet_scope_errors << "review/status bindings do not match validated lane pull requests" unless submission_pull_requests == expected_pull_requests
      packet_pull_requests = Array(review["pull_requests"]).filter_map do |item|
        item["identifier"].to_s[/([0-9]+)\z/, 1]&.to_i
      end.sort
      packet_scope_errors << "pull_requests do not match validated lane pull requests" unless packet_pull_requests == expected_pull_requests
      if repo.github_slug && review.dig("traceability", "repository") != repo.github_slug
        packet_scope_errors << "traceability.repository does not match GitHub repository"
      end
      unless packet_scope_errors.empty?
        evidence << { "source" => review_relative_path.to_s, "finding" => packet_scope_errors.join("; ") }
        return route_hash(repo, "REVIEW_INBOX_INCOMPLETE", "release-verification", "review-inbox", "The review inbox packet is not bound to the active sprint, lanes, issues, and pull requests.", evidence, missing, open_gates)
      end
      evidence << { "source" => review_path.relative_path_from(repo.root).to_s, "finding" => "review packet status is #{review['status'].inspect}, evidence verdict is #{review.dig('evidence_completeness', 'verdict').inspect}, recommendation is #{review.dig('recommendation', 'outcome').inspect}" }
      unless %w[ready approved].include?(review["status"]) &&
             review.dig("evidence_completeness", "verdict") == "complete" &&
             review.dig("recommendation", "outcome") == "approve"
        return route_hash(repo, "REVIEW_INBOX_INCOMPLETE", "release-verification", "review-inbox", "The review inbox packet is missing complete evidence or an approve recommendation.", evidence, missing, open_gates)
      end

      delivery_evidence = validate_delivery_evidence(repo, plan_path.dirname, sprint_id)
      unless delivery_evidence["errors"].empty?
        evidence << { "source" => plan_path.dirname.relative_path_from(repo.root).to_s, "finding" => delivery_evidence["errors"].join("; ") }
        return route_hash(repo, "RELEASE_EVIDENCE_INVALID", "release-verification", "integration", "Committed release or outcome evidence is invalid.", evidence, missing, open_gates)
      end
      release = delivery_evidence["release"]
      outcome = delivery_evidence["outcome"]
      post_integration = delivery_phase(release) == "post_integration"

      review_submissions = Array(review.dig("traceability", "review_submissions"))
      transport_neutral_integration = true
      lane_review_results.each_value do |lane_result|
        pull_request = lane_result.critic["pull_request"]
        recorded_submission = review_submissions.find { |item| item["pull_request"] == pull_request }
        unless recorded_submission
          evidence << { "source" => review_path.relative_path_from(repo.root).to_s, "finding" => "missing review/status binding for PR ##{pull_request}" }
          return route_hash(repo, "LANE_REVIEW_SUBMISSION_UNVERIFIED", "release-verification", "review-inbox", "Every lane requires its own commit-bound critic status or human review record.", evidence, missing, open_gates)
        end
        begin
          pull_evidence = repo.github_pull_request_evidence(pull_request)
          github_policy = lane_github_policy(repo, lane_result)
          expected_base = github_policy.fetch("base_ref")
          dev_integration = expected_base == "dev"
          transport_neutral_integration &&= dev_integration
          unless review.dig("traceability", "base_ref") == expected_base
            raise CommandError, "review packet base_ref does not match the lane implementation's committed repository policy"
          end
          if post_integration
            integrated_sha = release["integrated_sha"].to_s
            remote_base_sha = repo.remote_branch_sha(expected_base)
            fetched_base_sha = repo.fetch_branch_head(expected_base)
            unless integrated_sha.match?(/\A[0-9a-f]{40}\z/i) && remote_base_sha == integrated_sha && fetched_base_sha == integrated_sha
              raise CommandError, "release integrated_sha does not equal the current remote integration branch head"
            end
            merge_commit_sha = pull_evidence["merge_commit_sha"].to_s
            unless merge_commit_sha.match?(/\A[0-9a-f]{40}\z/i) && repo.commit_exists?(merge_commit_sha) && repo.ancestor?(merge_commit_sha, integrated_sha)
              raise CommandError, "merged pull request commit is not contained in release integrated_sha"
            end
          end
          ref_identity_ok = pull_evidence["head_ref"] == lane_result.contract["branch"] &&
                            pull_evidence["base_ref"] == expected_base
          state_ok = if post_integration
                       pull_evidence["merged"] == true && pull_evidence["state"].to_s.downcase == "merged"
                     else
                       pull_evidence["state"].to_s.downcase == "open" && pull_evidence["draft"] == false
                     end
          unless ref_identity_ok && state_ok
            phase = post_integration ? "merged" : "open review-ready"
            raise CommandError, "pull request is not a #{phase} lane PR on the expected head/base refs"
          end
          checks = Array(pull_evidence["checks"])
          required_checks = github_policy.fetch("required_checks")
          checks_ok = required_checks_succeed?(checks, required_checks)
          merge_state_ok = post_integration || %w[CLEAN HAS_HOOKS].include?(pull_evidence["merge_state_status"].to_s.upcase)
          unless checks_ok && merge_state_ok
            raise CommandError, "live pull request checks or phase-appropriate merge state are not valid at the current head"
          end
          contract_path = contracts.find { |path| Verdify.safe_load_yaml(path)["lane_id"] == lane_result.contract["lane_id"] }
          lane_validator = LaneReviewValidator.new(
            repo: repo,
            contract_path: contract_path,
            closeout_path: plan_path.dirname.join("lanes/closeout/#{lane_result.contract['lane_id']}.closeout.yaml"),
            critic_path: plan_path.dirname.join("critic/#{lane_result.contract['lane_id']}.critic.yaml")
          )
          if dev_integration
            submission_validation = lane_validator.validate_critic_status(
              result: lane_result,
              pull_request_head_sha: pull_evidence["head_sha"]
            )
            unless recorded_submission["review_submission_head_sha"] == lane_result.critic_report_head_sha
              raise CommandError, "recorded critic status head does not match the critic report head"
            end
          else
            reviewer_permission = repo.github_collaborator_permission(recorded_submission["reviewer_login"])
            unless reviewer_permission["login"].to_s.casecmp?(recorded_submission["reviewer_login"].to_s) &&
                   reviewer_permission["id"] == recorded_submission["reviewer_id"]
              raise CommandError, "recorded reviewer identity does not match GitHub collaborator identity"
            end
            submission_validation = lane_validator.validate_submission(
              result: lane_result,
              review_submission_head_sha: recorded_submission["review_submission_head_sha"],
              expected_reviewer_login: recorded_submission["reviewer_login"],
              expected_reviewer_id: recorded_submission["reviewer_id"],
              reviewer_permission: reviewer_permission["permission"],
              pull_request_head_sha: pull_evidence["head_sha"],
              pull_request_author: pull_evidence["author"],
              pull_request_author_id: pull_evidence["author_id"],
              submitted_reviews: pull_evidence["reviews"]
            )
          end
        rescue CommandError => e
          evidence << { "source" => "GitHub PR ##{pull_request}", "finding" => e.message }
          return route_hash(repo, "LANE_REVIEW_SUBMISSION_UNVERIFIED", "release-verification", "review-inbox", "Live current-head critic or GitHub review evidence could not be verified.", evidence, missing, open_gates)
        end
        unless submission_validation.valid?
          evidence << { "source" => "GitHub PR ##{pull_request}", "finding" => submission_validation.errors.join("; ") }
          return route_hash(repo, "LANE_REVIEW_SUBMISSION_UNVERIFIED", "release-verification", "review-inbox", "The phase-appropriate critic or human review evidence does not agree with the live pull-request head.", evidence, missing, open_gates)
        end
      end

      if release.nil? || release["status"] == "pending"
        missing << plan_path.dirname.join("release/release-verification.yaml").relative_path_from(repo.root).to_s
        reason = if transport_neutral_integration
                   "All required critic-report heads have current transport-neutral critic status; integration evidence is missing."
                 else
                   "All required critic-report heads have current external admin or maintainer approval; integration evidence is missing."
                 end
        return route_hash(repo, "READY_FOR_INTEGRATION", "release-verification", "integration", reason, evidence, missing, open_gates)
      end
      if release["status"] == "integration_failed"
        return route_hash(repo, "INTEGRATION_FAILED", "release-verification", "integration", "The recorded integration attempt failed and requires fix-forward before deployment.", evidence, missing, open_gates)
      end
      unless release["status"] == "verified"
        return route_hash(repo, "DEPLOYMENT_NOT_VERIFIED", "release-verification", "deployment-verification", "The integrated revision has not been verified in the target environment.", evidence, missing, open_gates)
      end

      unless outcome && %w[accepted accepted_with_risks].include?(outcome["decision"])
        missing << plan_path.dirname.join("outcome/outcome-review.yaml").relative_path_from(repo.root).to_s
        return route_hash(repo, "OUTCOME_REVIEW_REQUIRED", "release-verification", "outcome-review", "Runtime verification exists but authorized outcome acceptance is missing or incomplete.", evidence, missing, open_gates)
      end

      receipt_schema_relative = "schemas/sprint-terminal-receipt.schema.yaml"
      receipt_cutover_active = repo.git("cat-file", "-e", "#{repo.head_sha}:#{receipt_schema_relative}", allow_failure: true).last.success?
      if receipt_cutover_active
        receipt_relative = SprintTerminalReceipt.paths(sprint_id).fetch(:receipt)
        missing << receipt_relative
        return route_hash(repo, "TERMINAL_RECEIPT_REQUIRED", "release-verification", "terminal-receipt", "Release and outcome evidence are accepted; generate and auto-merge the protected-dev terminal receipt before later implementation.", evidence, missing, open_gates)
      end

      route_hash(repo, "SPRINT_COMPLETE", "state-of-union", "strategy-review", "The current sprint is accepted and verified; reconcile the backlog against the north-star goal before selecting the next outcome.", evidence, missing, open_gates)
    end

    def route_for_strategy(repo, root, evidence, missing, open_gates)
      strategy_path = root.join("strategy/state-of-union.yaml")
      unless strategy_path.file?
        missing << strategy_path.relative_path_from(repo.root).to_s
        return route_hash(repo, "STATE_OF_UNION_MISSING", "state-of-union", "strategy-review", "Approved foundations exist, but no strategy/backlog reconciliation has been recorded.", evidence, missing, open_gates)
      end

      strategy = Verdify.safe_load_yaml(strategy_path)
      evidence << { "source" => strategy_path.relative_path_from(repo.root).to_s, "finding" => "state-of-union status is #{strategy['status'].inspect}" }
      unless strategy["status"] == "approved" && strategy.dig("approval", "status") == "approved"
        return route_hash(repo, "STATE_OF_UNION_UNAPPROVED", "state-of-union", "strategy-review", "The strategy/backlog reconciliation is missing approval.", evidence, missing, open_gates)
      end

      head = repo.head_sha
      baseline = strategy["baseline_sha"].to_s
      strategy_paths = [
        strategy_path,
        root.join("strategy/state-of-union.md"),
        root.join("strategy/github-backlog-sync.yaml")
      ].select(&:file?).map { |path| path.relative_path_from(repo.root).to_s }
      baseline_valid = baseline.match?(/\A[0-9a-f]{40}\z/i) &&
                       repo.commit_exists?(baseline) &&
                       repo.ancestor?(baseline, head)
      suffix_paths = if baseline_valid
                       repo.commits_between(baseline, head).flat_map { |commit| repo.changed_paths(commit) }.uniq.sort
                     else
                       []
                     end
      unauthorized_paths = suffix_paths - strategy_paths
      snapshot_errors = strategy_paths.filter_map do |relative|
        commit = repo.last_change_sha(relative, ref: head)
        path = repo.root.join(relative)
        relative unless commit && repo.file_at(commit, relative) == path.binread
      end
      if baseline_valid && unauthorized_paths.empty? && snapshot_errors.empty?
        return nil
      end

      findings = []
      findings << "baseline_sha must be a full ancestor commit" unless baseline_valid
      findings << "post-assessment changes include non-strategy paths: #{unauthorized_paths.join(', ')}" unless unauthorized_paths.empty?
      findings << "strategy artifacts are uncommitted or differ from HEAD: #{snapshot_errors.join(', ')}" unless snapshot_errors.empty?
      evidence << { "source" => strategy_path.relative_path_from(repo.root).to_s, "finding" => findings.join("; ") }

      route_hash(repo, "STATE_OF_UNION_STALE", "state-of-union", "strategy-refresh", "The approved strategy was assessed against a different repository baseline.", evidence, missing, open_gates)
    end

    def lane_github_policy(repo, lane_result)
      sprint_id = lane_result.contract["sprint_id"]
      lane_id = lane_result.contract["lane_id"]
      authority_sha = lane_result.dispatch_head_sha
      raise CommandError, "approved dispatch head is unavailable" unless authority_sha
      relative = ".agent-workflow/sprints/#{sprint_id}/release/wave-release-plan.yaml"
      content = repo.file_at(authority_sha, relative)
      policy = YAML.safe_load(content, permitted_classes: [], aliases: false) || {}
      schema = SchemaValidator.load_document(Verdify::ROOT.join("schemas/wave-release-plan.schema.yaml"))
      validation_errors = SchemaValidator.new.validate(policy, schema) + SemanticValidator.validate(policy)
      validation_errors << "wave release plan must be approved" unless policy["status"] == "approved" && policy.dig("approval", "status") == "approved"
      validation_errors << "wave release plan sprint_id must match the lane" unless policy.dig("scope", "sprint_id") == sprint_id
      validation_errors << "wave release plan must include the lane" unless Array(policy.dig("scope", "lane_ids")).include?(lane_id)
      if repo.github_slug && policy.dig("github", "repository") != repo.github_slug
        validation_errors << "wave release plan repository must match the GitHub remote"
      end
      working_path = repo.root.join(relative)
      validation_errors << "controller wave release plan must match the approved lane-contract snapshot" unless working_path.file? && working_path.binread == content
      base_ref = policy.dig("branch_model", "base_ref").to_s
      required_checks = Array(policy.dig("github", "required_checks")).map(&:to_s).reject(&:empty?)
      required_checks << "critic-gate" if base_ref == "dev"
      required_checks.uniq!
      validation_errors << "wave release plan must define a base_ref and required checks" if base_ref.empty? || required_checks.empty?
      raise CommandError, validation_errors.join("; ") unless validation_errors.empty?

      { "base_ref" => base_ref, "required_checks" => required_checks }
    rescue Psych::Exception, CommandError => e
      raise CommandError, "could not load the wave release policy from the approved lane-contract snapshot: #{e.message}"
    end

    def validate_delivery_evidence(repo, sprint_root, sprint_id)
      result = { "release" => nil, "outcome" => nil, "errors" => [] }
      {
        "release" => [sprint_root.join("release/release-verification.yaml"), "release-verification.schema.yaml"],
        "outcome" => [sprint_root.join("outcome/outcome-review.yaml"), "outcome-review.schema.yaml"]
      }.each do |name, (path, schema_name)|
        next unless path.file?

        relative = path.relative_path_from(repo.root)
        commit = repo.last_change_sha(relative, ref: repo.head_sha)
        unless commit && repo.file_at(commit, relative) == path.binread
          result["errors"] << "#{relative}: artifact is uncommitted or differs from its committed snapshot"
          next
        end
        document = Verdify.safe_load_yaml(path)
        errors = SchemaValidator.new.validate(document, SchemaValidator.load_document(Verdify::ROOT.join("schemas", schema_name)))
        errors.concat(SemanticValidator.validate(document))
        errors << "sprint_id must match the active sprint" unless document["sprint_id"] == sprint_id
        if name == "release" && document["status"] == "verified"
          integrated_sha = document["integrated_sha"].to_s
          errors << "verified release integrated_sha must be a full commit SHA" unless integrated_sha.match?(/\A[0-9a-f]{40}\z/i)
          errors << "verified deployment observed_revision must equal integrated_sha" unless document.dig("deployment", "observed_revision") == integrated_sha
          errors << "verified release cannot contain failed integration results" if Array(document["integration_results"]).any? { |item| item["result"] == "failed" }
          errors << "verified release cannot contain failed runtime checks" if Array(document["runtime_checks"]).any? { |item| item["result"] == "failed" }
          errors << "verified release must record verified_at and verifier" if document["verified_at"].to_s.empty? || document["verifier"].to_s.empty?
        end
        result["errors"].concat(errors.map { |error| "#{relative}: #{error}" })
        result[name] = document
      end
      if result["outcome"] && !result["release"]
        result["errors"] << "outcome review cannot precede release verification"
      end
      result
    rescue CommandError => e
      result["errors"] << e.message
      result
    end

    def delivery_phase(release)
      return "pre_integration" unless release

      %w[ready_for_deployment deployment_failed rolled_back verified].include?(release["status"]) ? "post_integration" : "pre_integration"
    end

    def required_checks_succeed?(checks, required_names)
      return false if required_names.empty?

      required_names.all? do |required_name|
        matches = checks.select { |check| check["name"] == required_name }
        next false if matches.empty?

        latest = if matches.length == 1
                   matches.first
                 elsif matches.all? { |check| !(check["started_at"] || check["completed_at"]).to_s.empty? }
                   matches.max_by do |check|
                     [check["started_at"] || check["completed_at"], check["id"].to_s]
                   end
                 end
        terminal = latest && (latest["status"].to_s.empty? || latest["status"].to_s.upcase == "COMPLETED")
        terminal && latest["conclusion"].to_s.upcase == "SUCCESS"
      end
    end

    def strategy_handoff_route(repo, root, evidence, missing, open_gates)
      strategy_path = root.join("strategy/state-of-union.yaml")
      strategy = Verdify.safe_load_yaml(strategy_path)
      handoff = strategy["handoff"] || {}
      skill = handoff["next_skill"].to_s
      mode = handoff["next_mode"].to_s
      reason = handoff["reason"].to_s
      if skill.empty? || mode.empty? || reason.empty?
        return route_hash(repo, "STATE_OF_UNION_HANDOFF_INCOMPLETE", "state-of-union", "strategy-review", "The approved strategy does not name a complete handoff.", evidence, missing, open_gates)
      end

      hygiene_route = route_for_repo_hygiene(repo, root, evidence, missing, open_gates) if skill == "sprint-planning"
      return hygiene_route if hygiene_route

      route_hash(repo, "STATE_OF_UNION_HANDOFF", skill, mode, reason, evidence, missing, open_gates)
    end

    def route_for_pending_transcript_replan(repo, root, evidence, missing, open_gates)
      sources = Dir[repo.root.join("docs/northstar/evidence/*")].map { |path| Pathname.new(path) }.select(&:file?)
      return nil if sources.empty?

      intake_path = root.join("intake/transcript-replan.yaml")
      if intake_path.file?
        intake = Verdify.safe_load_yaml(intake_path)
        evidence << { "source" => intake_path.relative_path_from(repo.root).to_s, "finding" => "transcript-replan status is #{intake['status'].inspect}" }
        return nil if %w[routed approved].include?(intake["status"])
      else
        missing << intake_path.relative_path_from(repo.root).to_s
      end

      sources.first(5).each do |source|
        evidence << { "source" => source.relative_path_from(repo.root).to_s, "finding" => "north-star evidence has not been routed into .agent-workflow" }
      end
      route_hash(repo, "TRANSCRIPT_REPLAN_REQUIRED", "transcript-replan", "ingest", "North Star evidence exists and has not been converted into a routed transcript-replan artifact.", evidence, missing, open_gates)
    end

    def route_for_pending_northstar_research_ingest(repo, root, evidence, missing, open_gates)
      sources = [
        Dir[root.join("northstar/research-inbox/*")],
        Dir[repo.root.join("docs/northstar/research/*")]
      ].flatten.map { |path| Pathname.new(path) }.select(&:file?)
      return nil if sources.empty?

      registry_path = root.join("northstar/evidence-registry.yaml")
      registered = if registry_path.file?
                     registry = Verdify.safe_load_yaml(registry_path)
                     Array(registry["evidence"]).map { |entry| entry["source_sha256"] }
                   else
                     missing << registry_path.relative_path_from(repo.root).to_s
                     []
                   end
      unregistered = sources.reject { |source| registered.include?(Digest::SHA256.file(source).hexdigest) }
      return nil if unregistered.empty?

      unregistered.first(5).each do |source|
        evidence << {
          "source" => source.relative_path_from(repo.root).to_s,
          "finding" => "research source has not been registered in the North Star evidence registry"
        }
      end
      route_hash(repo, "NORTHSTAR_RESEARCH_INGEST_REQUIRED", "northstar-research-ingest", "ingest-research", "Research sources exist but have not been copied into collateral and registered as queryable North Star evidence.", evidence, missing, open_gates)
    end

    def route_for_pending_northstar_plan(repo, root, evidence, missing, open_gates)
      intake_path = root.join("intake/transcript-replan.yaml")
      evidence_sources = Dir[repo.root.join("docs/northstar/evidence/*")].map { |path| Pathname.new(path) }.select(&:file?)
      registry_path = root.join("northstar/evidence-registry.yaml")
      registry = registry_path.file? ? Verdify.safe_load_yaml(registry_path) : nil
      registry_has_evidence = registry.is_a?(Hash) && !Array(registry["evidence"]).empty?
      return nil unless intake_path.file? || !evidence_sources.empty? || registry_has_evidence

      if intake_path.file?
        intake = Verdify.safe_load_yaml(intake_path)
        intake_source = intake_path.relative_path_from(repo.root).to_s
        unless evidence.any? { |item| item["source"] == intake_source }
          evidence << { "source" => intake_source, "finding" => "transcript-replan status is #{intake['status'].inspect}" }
        end
        return nil unless %w[routed approved].include?(intake["status"])
      end

      if registry_has_evidence
        evidence << {
          "source" => registry_path.relative_path_from(repo.root).to_s,
          "finding" => "registered North Star evidence count is #{Array(registry['evidence']).length}"
        }
      end

      product_path = root.join("northstar/NORTHSTAR_PRODUCT.md")
      architecture_path = root.join("northstar/NORTHSTAR_ARCHITECTURE.md")
      artifacts_path = root.join("northstar/northstar-artifacts.yaml")
      artifacts_present = [product_path, architecture_path, artifacts_path].all?(&:file?)

      plan_path = root.join("northstar/northstar-plan.yaml")
      unless plan_path.file? || artifacts_present
        missing << plan_path.relative_path_from(repo.root).to_s
        return route_hash(repo, "NORTHSTAR_PLAN_MISSING", "northstar-planning", "intake", "Planning evidence has been routed, but no North Star planning artifact exists.", evidence, missing, open_gates)
      end

      if plan_path.file?
        plan = Verdify.safe_load_yaml(plan_path)
        evidence << { "source" => plan_path.relative_path_from(repo.root).to_s, "finding" => "northstar-plan status is #{plan['status'].inspect}" }
        unless artifacts_present || (%w[approved].include?(plan["status"]) && plan.dig("approval", "status") == "approved")
          return route_hash(repo, "NORTHSTAR_PLAN_INCOMPLETE", "northstar-planning", "synthesis", "North Star planning exists but is not approved.", evidence, missing, open_gates)
        end
      end

      [product_path, architecture_path, artifacts_path].each do |path|
        missing << path.relative_path_from(repo.root).to_s unless path.file?
      end
      unless missing.none? { |item| item.start_with?(".agent-workflow/northstar/NORTHSTAR_") || item == ".agent-workflow/northstar/northstar-artifacts.yaml" }
        return route_hash(repo, "NORTHSTAR_ARTIFACTS_MISSING", "northstar-planning", "artifact-loop", "North Star evidence is routed, but product/architecture North Star artifacts or their signoff record are missing.", evidence, missing, open_gates)
      end

      artifacts = Verdify.safe_load_yaml(artifacts_path)
      artifact_status = artifacts["status"].to_s
      evidence << { "source" => artifacts_path.relative_path_from(repo.root).to_s, "finding" => "northstar-artifacts status is #{artifact_status.inspect}" }
      product_ok = artifacts.dig("product", "status") == "approved"
      architecture_ok = artifacts.dig("architecture", "status") == "approved"
      review_ok = artifacts.dig("review", "status") == "approved"
      return nil if artifact_status == "approved" && product_ok && architecture_ok && review_ok

      mode = if artifact_status == "review_requested" || artifacts.dig("review", "status") == "requested"
               "human-review"
             elsif artifact_status == "blocked"
               artifacts.dig("handoff", "next_mode").to_s.empty? ? "artifact-loop" : artifacts.dig("handoff", "next_mode")
             else
               "artifact-loop"
             end
      route_hash(repo, "NORTHSTAR_ARTIFACTS_INCOMPLETE", "northstar-planning", mode, "Product and architecture North Star artifacts must be cross-linked and signed off before downstream lifecycle skills treat them as core planning authority.", evidence, missing, open_gates)
    end

    def route_for_repo_hygiene(repo, root, evidence, missing, open_gates)
      hygiene_path = root.join("hygiene/repo-hygiene.yaml")
      unless hygiene_path.file?
        missing << hygiene_path.relative_path_from(repo.root).to_s
        return route_hash(repo, "REPO_HYGIENE_MISSING", "repo-hygiene", "assess", "Approved strategy is ready for sprint planning, but Wave 0 repo hygiene is missing.", evidence, missing, open_gates)
      end

      hygiene = Verdify.safe_load_yaml(hygiene_path)
      evidence << { "source" => hygiene_path.relative_path_from(repo.root).to_s, "finding" => "repo-hygiene status is #{hygiene['status'].inspect}" }
      return nil if hygiene["status"] == "complete" && hygiene.dig("approval", "status") == "approved"

      route_hash(repo, "REPO_HYGIENE_INCOMPLETE", "repo-hygiene", "assess", "Repo hygiene must be complete and approved before sprint planning.", evidence, missing, open_gates)
    end

    def route_hash(repo, state, skill, mode, reason, evidence, missing, open_gates)
      ensure_declared_lifecycle_mode!(skill, mode)

      {
        "schema_ref" => "route-decision.schema.yaml",
        "kind" => "RouteDecision",
        "schema_version" => "1.0",
        "generated_at" => Verdify.utc_now,
        "repository" => repo.github_slug || "local/#{repo.root.basename}",
        "current_state" => state,
        "next_skill" => skill,
        "next_mode" => mode,
        "reason" => reason,
        "evidence" => evidence,
        "missing_artifacts" => missing.uniq,
        "open_gates" => open_gates
      }
    end

    def ensure_declared_lifecycle_mode!(skill, mode)
      modes = lifecycle_modes[skill.to_s]
      return if modes&.include?(mode.to_s)

      raise UsageError, "route next_mode #{mode.inspect} is not declared for #{skill} in config/lifecycle.yaml"
    end

    def lifecycle_modes
      @lifecycle_modes ||= begin
        config = Verdify.safe_load_yaml(Verdify::ROOT.join("config/lifecycle.yaml"))
        Array(config["skills"]).to_h { |entry| [entry["name"].to_s, Array(entry["modes"]).map(&:to_s)] }
      end
    end

    def route_for_gate(type)
      case type
      when "project_definition" then ["project-definition", "design-surface"]
      when "northstar" then ["northstar-planning", "human-review"]
      when "architecture" then ["architecture-contracts", "north-star-architecture"]
      when "strategy" then ["state-of-union", "gate-resolution"]
      when "repo_hygiene" then ["repo-hygiene", "compliance-gate"]
      when "platform_readiness" then ["platform-readiness", "readiness-gate"]
      when "gravity_readiness" then ["gravity-readiness", "readiness-checklist"]
      when "plan_approval" then ["sprint-planning", "plan-approval"]
      when "deployment_approval" then ["release-verification", "deployment-verification"]
      when "incident" then ["release-verification", "observability-diagnostics"]
      when "outcome_acceptance" then ["release-verification", "outcome-review"]
      else ["sprint-orchestrator", "gate-management"]
      end
    end

    def approved_gate?(path, type)
      return false unless path.file?

      gate = Verdify.safe_load_yaml(path)
      gate["type"] == type && gate["status"] == "approved"
    rescue Error
      false
    end

    def resolve_contract_path(repo, sprint, lane_id, supplied)
      path = supplied ? resolve_repo_path(repo, supplied) : repo.root.join(".agent-workflow/sprints", sprint, "lanes/contracts/#{lane_id}.contract.yaml")
      raise UsageError, "lane contract not found: #{path}" unless path.file?
      path
    end

    def find_contract_by_lane(repo, lane_id)
      matches = Dir[repo.root.join(".agent-workflow/sprints/*/lanes/contracts/#{lane_id}.contract.yaml")].map { |p| Pathname.new(p) }
      raise UsageError, "no contract found for lane #{lane_id}" if matches.empty?
      raise UsageError, "multiple contracts found for lane #{lane_id}; specify a unique lane ID" if matches.length > 1
      matches.first
    end

    def load_and_validate_contract(path)
      contract = Verdify.safe_load_yaml(path)
      errors = SchemaValidator.new.validate(contract, SchemaValidator.load_document(Verdify::ROOT.join("schemas/lane-contract.schema.yaml")))
      errors.concat(SemanticValidator.validate(contract))
      raise UsageError, "invalid lane contract #{path}:\n#{errors.join("\n")}" unless errors.empty?
      contract
    end

    def load_lane_dispatch_artifacts(contract_path, contract)
      source_repo = GitRepository.new(contract_path.dirname)
      sprint_root = source_repo.root.join(".agent-workflow/sprints", contract["sprint_id"])
      paths = [
        sprint_root.join("sprint-plan.yaml"),
        sprint_root.join("release/wave-release-plan.yaml"),
        contract_path
      ]
      paths.each { |path| raise UsageError, "approved lane dispatch artifact not found: #{path}" unless path.file? }
      plan = Verdify.safe_load_yaml(paths[0])
      wave = Verdify.safe_load_yaml(paths[1])
      validation_errors = []
      {
        paths[0] => "sprint-plan.schema.yaml",
        paths[1] => "wave-release-plan.schema.yaml"
      }.each do |path, schema_name|
        document = path == paths[0] ? plan : wave
        errors = SchemaValidator.new.validate(document, SchemaValidator.load_document(Verdify::ROOT.join("schemas", schema_name)))
        errors.concat(SemanticValidator.validate(document))
        validation_errors.concat(errors.map { |error| "#{path}: #{error}" })
      end
      planned_lane = Array(plan["lanes"]).find { |lane| lane["lane_id"] == contract["lane_id"] }
      validation_errors << "sprint plan must be approved" unless plan.dig("approval", "status") == "approved"
      validation_errors << "sprint plan must identify the approved lane contract and branch" unless planned_lane &&
                                                                                               planned_lane["contract_path"] == contract_path.relative_path_from(source_repo.root).to_s &&
                                                                                               planned_lane["branch"] == contract["branch"]
      validation_errors << "wave release plan must be approved" unless wave["status"] == "approved" && wave.dig("approval", "status") == "approved"
      validation_errors << "wave release plan must include the lane" unless wave.dig("scope", "sprint_id") == contract["sprint_id"] &&
                                                                          Array(wave.dig("scope", "lane_ids")).include?(contract["lane_id"])
      paths.each do |path|
        relative = path.relative_path_from(source_repo.root)
        commit = source_repo.last_change_sha(relative, ref: source_repo.head_sha)
        unless commit && source_repo.file_at(commit, relative) == path.binread
          validation_errors << "#{relative}: dispatch artifact must be committed exactly at the source HEAD"
        end
      end
      raise UsageError, "invalid lane dispatch transaction:\n#{validation_errors.join("\n")}" unless validation_errors.empty?

      paths.map do |path|
        [path.relative_path_from(source_repo.root).to_s, path.binread]
      end
    end

    def seed_lane_dispatch_artifacts(worktree_path, artifacts, lane_id)
      worktree = Pathname.new(worktree_path)
      artifacts.each do |relative, content|
        destination = worktree.join(relative)
        FileUtils.mkdir_p(destination.dirname)
        Verdify.atomic_write(destination, content) unless destination.file? && destination.binread == content
      end
      worktree_repo = GitRepository.new(worktree)
      worktree_repo.git("add", "--", *artifacts.map(&:first))
      staged = worktree_repo.git("diff", "--cached", "--quiet", allow_failure: true)
      return if staged.last.success?

      worktree_repo.git("commit", "-m", "chore(verdify): seed approved dispatch for #{lane_id}")
    end

    def enforce_lane_contract!(contract, options)
      raise UsageError, "contract lane_id does not match --lane-id" unless contract["lane_id"] == options[:lane_id]
      raise UsageError, "contract sprint_id does not match --sprint" unless contract["sprint_id"] == options[:sprint]
      raise UsageError, "issue ##{options[:issue]} is not assigned to the lane" unless contract["issue_ids"].map(&:to_i).include?(options[:issue])
      raise UsageError, "lane contract is not approved" unless %w[approved dispatched changes_requested].include?(contract["status"])
      raise UsageError, "lane approval is not approved" unless contract.dig("approval", "status") == "approved"
      if contract["issue_ids"].length > 1 && contract["coupling_justification"].to_s.strip.empty?
        raise UsageError, "multi-issue lane requires coupling_justification"
      end
      unless contract.dig("worktree_policy", "one_coding_session_per_worktree") == true && contract.dig("worktree_policy", "lock_required") == true
        raise UsageError, "contract must require one coding session per locked worktree"
      end
    end

    def build_lease(repo:, lease_id:, sprint_id:, lane_id:, issue_ids:, role:, agent:, session_id:, branch:, baseline_sha:, contract_path:, worktree_path:, ttl_hours:)
      now = Time.now.utc
      {
        "schema_ref" => "lane-lease.schema.yaml",
        "kind" => "LaneLease",
        "schema_version" => "1.0",
        "lease_id" => lease_id,
        "sprint_id" => sprint_id,
        "lane_id" => lane_id,
        "issue_ids" => issue_ids.map(&:to_i),
        "role" => role,
        "agent" => agent,
        "session_id" => session_id,
        "branch" => branch,
        "baseline_sha" => baseline_sha,
        "contract_path" => contract_path.expand_path.to_s,
        "contract_hash" => Digest::SHA256.file(contract_path).hexdigest,
        "worktree_path" => worktree_path.expand_path.to_s,
        "created_at" => now.iso8601,
        "expires_at" => (now + ttl_hours.to_i * 3600).iso8601,
        "released_at" => nil,
        "status" => "active",
        "runtime_namespace" => runtime_namespace(lease_id)
      }
    end

    def runtime_namespace(seed)
      slug = Verdify.slug(seed, max: 38)
      underscored = slug.tr("-", "_")
      {
        "compose_project" => "verdify_#{underscored}"[0, 63],
        "database_suffix" => underscored[0, 40],
        "kubernetes_namespace" => "lane-#{slug}"[0, 63].gsub(/-+\z/, ""),
        "port_offset" => 1000 + (Digest::SHA256.hexdigest(seed)[0, 6].to_i(16) % 20_000),
        "cache_prefix" => "verdify:#{slug}:"
      }
    end

    def print_lease_summary(lease)
      puts "Lease: #{lease['lease_id']}"
      puts "Role: #{lease['role']}"
      puts "Lane: #{lease['lane_id']}"
      puts "Branch: #{lease['branch']}"
      puts "Worktree: #{lease['worktree_path']}"
      puts "Expires: #{lease['expires_at']}"
      puts "Runtime environment:"
      puts "  export COMPOSE_PROJECT_NAME=#{lease.dig('runtime_namespace', 'compose_project')}"
      puts "  export VERDIFY_TEST_DB_SUFFIX=#{lease.dig('runtime_namespace', 'database_suffix')}"
      puts "  export VERDIFY_K8S_NAMESPACE=#{lease.dig('runtime_namespace', 'kubernetes_namespace')}"
      puts "  export VERDIFY_PORT_OFFSET=#{lease.dig('runtime_namespace', 'port_offset')}"
      puts "  export VERDIFY_CACHE_PREFIX=#{Shellwords.escape(lease.dig('runtime_namespace', 'cache_prefix'))}"
    end

    def lease_dir(repo)
      repo.common_dir.join("verdify/leases")
    end

    def lease_path(repo, lease_id)
      lease_dir(repo).join("#{Verdify.slug(lease_id, max: 96)}.json")
    end

    def with_lease_lock(repo)
      FileUtils.mkdir_p(lease_dir(repo))
      File.open(lease_dir(repo).join(".lease.lock"), File::RDWR | File::CREAT, 0o600) do |file|
        file.flock(File::LOCK_EX)
        yield
      ensure
        file.flock(File::LOCK_UN) unless file.closed?
      end
    end

    def write_lease(repo, lease)
      validate_hash!(lease, "lane-lease.schema.yaml", "lane lease")
      FileUtils.mkdir_p(lease_dir(repo))
      Verdify.atomic_write(lease_path(repo, lease["lease_id"]), JSON.pretty_generate(lease) + "\n")
    end

    def active_worker_lease(repo, lane_id)
      all_leases(repo).find do |lease|
        lease["role"] == "worker" && lease["lane_id"] == lane_id && lease["status"] == "active"
      end
    end

    def all_leases(repo)
      Dir[lease_dir(repo).join("*.json")].sort.each_with_object([]) do |path, leases|
        begin
          leases << load_json(path)
        rescue Error
          next
        end
      end
    end

    def expire_stale_leases!(repo)
      all_leases(repo).each do |lease|
        next unless lease["status"] == "active"
        next unless Time.parse(lease["expires_at"]) <= Time.now.utc
        lease["status"] = "expired"
        write_lease(repo, lease)
      rescue StandardError
        next
      end
    end

    def default_worktree_path(repo, lane_id)
      repo.root.dirname.join(".worktrees", repo.root.basename.to_s, Verdify.slug(lane_id))
    end

    def default_review_path(repo, lane_id, session_id)
      repo.root.dirname.join(".reviews", repo.root.basename.to_s, "#{Verdify.slug(lane_id)}-#{Verdify.slug(session_id, max: 24)}")
    end

    def validate_hash!(document, schema_name, label)
      schema = SchemaValidator.load_document(Verdify::ROOT.join("schemas", schema_name))
      errors = SchemaValidator.new.validate(document, schema)
      errors.concat(SemanticValidator.validate(document))
      raise Error, "#{label} failed validation:\n#{errors.join("\n")}" unless errors.empty?
    end

    def skill_packs
      Dir[Verdify::ROOT.join("packs/*/pack.yaml")].sort.map do |path|
        load_skill_pack(Pathname.new(path).dirname.basename.to_s)
      end
    end

    def load_skill_pack(name)
      raise UsageError, "invalid pack name: #{name.inspect}" unless name.to_s.match?(/\A[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\z/)

      path = Verdify::ROOT.join("packs", name, "pack.yaml")
      raise UsageError, "unknown skill pack #{name.inspect}; run `verdify pack list`" unless path.file?

      pack = Verdify.safe_load_yaml(path)
      validate_hash!(pack, "skill-pack.schema.yaml", "skill pack #{name}")
      raise UsageError, "pack name does not match directory: #{name}" unless pack["name"] == name

      unknown = pack_skill_names(pack, true) - all_skill_names
      raise UsageError, "pack #{name} references unknown skills: #{unknown.join(', ')}" unless unknown.empty?

      pack
    end

    def pack_skill_names(pack, include_optional)
      skills = Array(pack.dig("includes", "required")).map(&:to_s)
      skills += Array(pack.dig("includes", "optional")).map(&:to_s) if include_optional
      skills.uniq
    end

    def all_skill_names
      Dir[Verdify::ROOT.join("skills/*/SKILL.md")].sort.map { |path| Pathname.new(path).dirname.basename.to_s }
    end

    def install_pack_transaction(repo_root, pack, skills, options)
      hosts = options[:host] == "all" ? %w[codex claude] : [options[:host]]
      host_dirs = { "codex" => ".agents/skills", "claude" => ".claude/skills" }
      manifest_path = repo_root.join(".agent-skills/verdify-packs/#{pack['name']}.yaml")
      manifest_content = pack_manifest_content(pack, skills, options)
      targets = hosts.flat_map do |current_host|
        skills.map do |skill|
          source = Verdify::ROOT.join("skills", skill)
          raise UsageError, "missing source skill #{skill}" unless source.join("SKILL.md").file?

          {
            path: repo_root.join(host_dirs.fetch(current_host), skill),
            kind: :symlink,
            source: source
          }
        end
      end
      targets << { path: manifest_path, kind: :file, content: manifest_content }

      targets.each do |target|
        ensure_pack_parent_path!(repo_root, target.fetch(:path).dirname)
        path = target.fetch(:path)
        next unless path.exist? || path.symlink?

        same = if target.fetch(:kind) == :symlink
                 begin
                   path.symlink? && path.realpath == target.fetch(:source).realpath
                 rescue Errno::ENOENT
                   false
                 end
               else
                 path.file? && !path.symlink? && path.read == target.fetch(:content)
               end
        target[:keep] = same
        raise UsageError, "refusing to replace #{path}; pass --force" unless same || options[:force]
      end

      changed_targets = targets.reject { |target| target[:keep] }
      operator_targets = changed_targets.select { |target| pack_path_present?(target.fetch(:path)) }
      backup_root = Pathname.new(Dir.mktmpdir("verdify-pack-rollback-"))
      backups = {}
      created_paths = []
      replaced_paths = []
      created_dirs = []
      committed = false
      rollback_errors = []

      begin
        # Copy and verify every operator-owned target before the first mutation.
        # A backup failure therefore leaves the entire destination tree intact.
        operator_targets.each_with_index do |target, index|
          path = target.fetch(:path)
          inject_pack_failure!("backup-#{index}")
          backup = backup_root.join(index.to_s)
          snapshot = pack_path_snapshot(path)
          copy_pack_backup!(path, backup, snapshot)
          backups[path.to_s] = { path: path, backup: backup, snapshot: snapshot }
        end

        changed_targets.each_with_index do |target, index|
          path = target.fetch(:path)
          inject_pack_failure!("write-#{index}")
          if (backup = backups[path.to_s])
            raise Error, "pack target changed after backup: #{path}" unless pack_path_snapshot(path) == backup.fetch(:snapshot)

            FileUtils.rm_rf(path)
            replaced_paths << path
          end

          missing = []
          cursor = path.dirname
          until cursor == repo_root || cursor.exist? || cursor.symlink?
            missing << cursor
            cursor = cursor.dirname
          end
          FileUtils.mkdir_p(path.dirname)
          created_dirs.concat(missing.reverse)

          if target.fetch(:kind) == :symlink
            source = target.fetch(:source)
            File.symlink(source.relative_path_from(path.dirname), path)
            created_paths << path unless backups.key?(path.to_s)
          end
        end

        inject_pack_failure!("before-manifest")

        manifest_target = changed_targets.find { |target| target.fetch(:kind) == :file }
        if manifest_target
          Verdify.atomic_write(manifest_target.fetch(:path), manifest_target.fetch(:content))
          manifest_path = manifest_target.fetch(:path)
          created_paths << manifest_path unless backups.key?(manifest_path.to_s)
        end
        inject_pack_failure!("after-manifest")
        committed = true
      rescue StandardError => original_error
        created_paths.reverse_each do |path|
          FileUtils.rm_rf(path) if pack_path_present?(path)
        rescue StandardError => rollback_error
          rollback_errors << "remove created #{path}: #{rollback_error.message}"
        end
        replaced_paths.reverse_each.with_index do |path, index|
          backup = backups.fetch(path.to_s)
          begin
            restore_pack_backup!(path, backup_root, backup.fetch(:backup), backup.fetch(:snapshot), index)
          rescue StandardError => rollback_error
            rollback_errors << "restore #{path}: #{rollback_error.message}"
          end
        end
        created_dirs.reverse_each do |dir|
          Dir.rmdir(dir) if dir.directory? && dir.children.empty?
        rescue StandardError => rollback_error
          rollback_errors << "remove directory #{dir}: #{rollback_error.message}"
        end
        unless rollback_errors.empty?
          raise Error, "#{original_error.message}; rollback incomplete (#{rollback_errors.join('; ')}); verified backups retained at #{backup_root}"
        end
        raise original_error
      ensure
        FileUtils.rm_rf(backup_root) if committed || rollback_errors.empty?
      end
    end

    def pack_path_present?(path)
      path.exist? || path.symlink?
    end

    def pack_path_snapshot(path)
      stat = path.lstat
      mode = stat.mode & 0o7777
      if stat.symlink?
        [:symlink, mode, path.readlink.to_s]
      elsif stat.file?
        [:file, mode, stat.size, Digest::SHA256.file(path).hexdigest]
      elsif stat.directory?
        children = path.children.sort_by { |child| child.basename.to_s }.map do |child|
          [child.basename.to_s, pack_path_snapshot(child)]
        end
        [:directory, mode, children]
      else
        raise UsageError, "pack target has unsupported file type: #{path}"
      end
    end

    def copy_pack_backup!(path, backup, expected_snapshot)
      staging = backup.sub_ext(".staging")
      FileUtils.rm_rf(staging)
      FileUtils.copy_entry(path, staging, true, false, true)
      raise Error, "pack backup verification failed for #{path}" unless pack_path_snapshot(staging) == expected_snapshot

      File.rename(staging, backup)
      fsync_pack_backup!(backup)
      raise Error, "pack backup changed while becoming durable for #{path}" unless pack_path_snapshot(backup) == expected_snapshot
    ensure
      FileUtils.rm_rf(staging) if staging && pack_path_present?(staging)
    end

    def fsync_pack_backup!(path)
      if path.file? && !path.symlink?
        File.open(path, "rb", &:fsync)
      elsif path.directory? && !path.symlink?
        path.children.each { |child| fsync_pack_backup!(child) }
      end
      File.open(path.dirname, File::RDONLY, &:fsync)
    rescue Errno::EINVAL, Errno::ENOTSUP
      # Some filesystems do not expose directory fsync; file contents were still
      # flushed and the verified backup remains available for rollback.
      nil
    end

    def restore_pack_backup!(path, backup_root, backup, expected_snapshot, index)
      restore = backup_root.join("restore-#{index}")
      FileUtils.rm_rf(restore)
      FileUtils.copy_entry(backup, restore, true, false, true)
      raise Error, "pack restore staging verification failed for #{path}" unless pack_path_snapshot(restore) == expected_snapshot

      FileUtils.rm_rf(path) if pack_path_present?(path)
      FileUtils.mkdir_p(path.dirname)
      File.rename(restore, path)
      raise Error, "pack restore verification failed for #{path}" unless pack_path_snapshot(path) == expected_snapshot
      inject_pack_failure!("restore-#{index}")
    ensure
      FileUtils.rm_rf(restore) if restore && pack_path_present?(restore)
    end

    def inject_pack_failure!(point)
      failures = ENV.fetch("VERDIFY_TEST_PACK_FAILURE", "").split(",")
      return unless ENV["VERDIFY_TESTING"] == "1" && failures.include?(point)

      raise Error, "injected pack transaction failure at #{point}"
    end

    def ensure_pack_parent_path!(repo_root, parent)
      relative = parent.relative_path_from(repo_root)
      cursor = repo_root
      relative.each_filename do |component|
        cursor = cursor.join(component)
        next unless cursor.exist? || cursor.symlink?

        raise UsageError, "pack destination parent is a symlink: #{cursor}" if cursor.symlink?
        raise UsageError, "pack destination parent is not a directory: #{cursor}" unless cursor.directory?
      end
    end

    def pack_manifest_content(pack, skills, options)
      manifest = {
        "schema_ref" => "skill-pack.schema.yaml",
        "kind" => "VerdifySkillPack",
        "schema_version" => "1.0",
        "name" => pack["name"],
        "display_name" => pack["display_name"],
        "description" => pack["description"],
        "category" => pack["category"],
        "maturity" => pack["maturity"],
        "includes" => {
          "required" => skills,
          "optional" => []
        },
        "provides" => pack["provides"],
        "depends_on" => pack["depends_on"],
        "conflicts" => pack["conflicts"],
        "install" => {
          "hosts" => options[:host] == "all" ? %w[codex claude] : [options[:host]],
          "default_profile" => pack.dig("install", "default_profile")
        }
      }
      validate_hash!(manifest, "skill-pack.schema.yaml", "installed skill pack manifest")
      YAML.dump(manifest)
    end

    def command_init_for_pack(repo, force)
      return if repo.root.join(".agent-workflow/config.yaml").file? && !force

      root = repo.root.join(".agent-workflow")
      FileUtils.mkdir_p(root)
      Verdify.atomic_write(root.join(".gitignore"), "github/snapshot.json\nruntime/\n*.tmp\nnorthstar/collateral/sources/\n")
      Verdify.atomic_write(root.join("README.md"), "# Verdify project artifacts\n\nCanonical approved definitions, architecture, module contracts, sprint contracts, gates, status, and evidence live here.\n")
      Verdify.atomic_write(root.join("config.yaml"), YAML.dump({
        "schema_ref" => "project-config.schema.yaml",
        "kind" => "VerdifyProjectConfig",
        "schema_version" => "1.0",
        "initialized_at" => Verdify.utc_now,
        "default_branch" => repo.default_branch,
        "github_repository" => repo.github_slug,
        "policy" => {
          "one_issue_per_lane" => true,
          "one_coding_session_per_worktree" => true,
          "fresh_critic_required" => true,
          "runtime_verification_required" => true
        }
      }))
    end

    def split_list(value)
      value.to_s.split(",").map(&:strip).reject(&:empty?)
    end

    def normalize_tags(tags)
      Array(tags).flat_map { |tag| split_list(tag) }
                 .map { |tag| Verdify.slug(tag, max: 48) }
                 .reject(&:empty?)
                 .uniq
                 .sort
    end

    def next_northstar_evidence_id(registry_path, title)
      date = Time.now.utc.strftime("%Y%m%d")
      base = "NSE-#{date}-#{Verdify.slug(title, max: 40)}"
      registry = registry_path.file? ? Verdify.safe_load_yaml(registry_path) : {}
      existing = Array(registry["evidence"]).map { |entry| entry["id"] }
      id = base
      counter = 2
      while existing.include?(id) || registry_path.dirname.join("collateral/#{id}.yaml").file?
        id = "#{base}-#{counter}"
        counter += 1
      end
      id
    end

    def load_northstar_registry(repo, registry_path, now)
      if registry_path.file?
        registry = Verdify.safe_load_yaml(registry_path)
        validate_hash!(registry, "northstar-evidence-registry.schema.yaml", "northstar evidence registry")
        registry
      else
        empty_northstar_registry(repo, now)
      end
    end

    def empty_northstar_registry(repo, now)
      {
        "schema_ref" => "northstar-evidence-registry.schema.yaml",
        "kind" => "NorthStarEvidenceRegistry",
        "schema_version" => "1.0",
        "project_id" => repo.github_slug || "local/#{repo.root.basename}",
        "generated_at" => now,
        "updated_at" => now,
        "evidence" => []
      }
    end

    def evidence_entry_matches?(entry, query, tags)
      entry_tags = normalize_tags(entry["tags"])
      return false unless tags.all? { |tag| entry_tags.include?(tag) }
      return true if query.empty?

      haystack = [
        entry["id"],
        entry["reference"],
        entry["title"],
        entry["summary"],
        entry["source_uri"],
        entry["item_path"],
        entry["copied_source_path"],
        Array(entry["tags"]).join(" "),
        Array(entry["claims"]).join(" "),
        Array(entry["planning_relevance"]).join(" ")
      ].compact.join(" ").downcase
      haystack.include?(query)
    end

    def scan_research_source_for_secrets!(path)
      findings = research_source_secret_findings(path)
      return if findings.empty?

      shown = findings.first(5).map { |finding| "#{finding[:type]} at line #{finding[:line]}" }
      suffix = findings.length > shown.length ? "; #{findings.length - shown.length} more" : ""
      raise UsageError, "research source failed secret scan: #{shown.join('; ')}#{suffix}. Remove secrets/PII or record a gate instead."
    end

    def research_source_secret_findings(path)
      text = File.binread(path).encode("UTF-8", invalid: :replace, undef: :replace, replace: "?")
      findings = []
      text.each_line.with_index(1) do |line, line_number|
        SECRET_SCAN_LINE_PATTERNS.each do |type, pattern|
          findings << { type: type, line: line_number } if line.match?(pattern)
        end
        if (match = line.match(SECRET_ASSIGNMENT_PATTERN)) && secret_like_value?(match[1])
          findings << { type: "credential assignment", line: line_number }
        end
        line.scan(CREDIT_CARD_CANDIDATE_PATTERN) do |candidate|
          findings << { type: "payment card number", line: line_number } if payment_card_number?(candidate)
        end
      end
      findings
    end

    def secret_like_value?(value)
      normalized = value.to_s.gsub(/\A["']|["',;]\z/, "")
      return false if normalized.length < 20
      return false if normalized.match?(/\A(?:redacted|example|placeholder|changeme|dummy|test|x+)\z/i)

      normalized.match?(/[A-Z]/) && normalized.match?(/[a-z]/) && normalized.match?(/[0-9]/) ||
        shannon_entropy(normalized) >= 3.5
    end

    def shannon_entropy(value)
      chars = value.each_char.to_a
      return 0.0 if chars.empty?

      counts = chars.tally
      counts.values.sum do |count|
        probability = count.to_f / chars.length
        -probability * Math.log2(probability)
      end
    end

    def payment_card_number?(candidate)
      digits = candidate.gsub(/\D/, "")
      return false unless digits.length.between?(13, 19)
      return false if digits.chars.uniq.length == 1
      return false unless digits.match?(/\A(?:4|5[1-5]|2[2-7]|3[47]|6(?:011|5)|35)/)

      luhn_checksum_valid?(digits)
    end

    def luhn_checksum_valid?(digits)
      sum = digits.reverse.chars.each_with_index.sum do |char, index|
        digit = char.to_i
        if index.odd?
          doubled = digit * 2
          doubled > 9 ? doubled - 9 : doubled
        else
          digit
        end
      end
      (sum % 10).zero?
    end

    def resolve_repo_path(repo, value)
      path = Pathname.new(value)
      path.absolute? ? path : repo.root.join(path).cleanpath
    end

    def load_json(path)
      JSON.parse(File.read(path))
    rescue JSON::ParserError => e
      raise Error, "JSON parse failed for #{path}: #{e.message}"
    end

    def strip_frontmatter(text)
      text.sub(/\A---[ \t]*\n.*?\n---[ \t]*\n/m, "")
    end

    def command_available?(name)
      !executable_path(name).nil?
    end

    def executable_path(name)
      ENV.fetch("PATH", "").split(File::PATH_SEPARATOR).map { |dir| File.join(dir, name) }
         .find { |path| File.file?(path) && File.executable?(path) }
    end

    def capture_external(*command)
      stdout, stderr, status = Open3.capture3(*command)
      raise CommandError, "Command failed (#{command.shelljoin}): #{stderr.strip.empty? ? stdout.strip : stderr.strip}" unless status.success?
      stdout
    end

    def check_record(name, ok, required, detail)
      { "name" => name, "ok" => !!ok, "required" => required, "detail" => detail.to_s }
    end
  end
end
