# frozen_string_literal: true

module Verdify
  class CLI
    SKILLS = %w[
      project-router
      project-definition
      architecture-contracts
      state-of-union
      sprint-planning
      sprint-orchestrator
      lane-delivery
      independent-critic
      release-verification
    ].freeze

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
      when "sprint" then command_sprint
      when "lane" then command_lane
      when "prompt" then command_prompt
      when "github" then command_github
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
          sprint init                Create a draft sprint skeleton and approval gate
          lane create                Create and lock one worker worktree/lease
          lane review                Create a fresh detached critic worktree/lease
          lane list                  List local Verdify leases and Git worktrees
          lane inspect               Inspect one lease and worktree status
          lane release               Release a lease and normally remove its worktree
          prompt compile             Compile a worker or critic prompt with input hashes
          github bootstrap           Preview/apply standard Verdify labels
          github snapshot            Cache current issues and pull requests locally
          github reconcile           Compare sprint lane contracts with a snapshot

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
        root.join(".gitignore") => "github/snapshot.json\nruntime/\n*.tmp\n",
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
      ].each { |relative| FileUtils.mkdir_p(root.join(relative)) }

      puts "Verdify initialized in #{repo.root}"
      0
    end

    def command_route
      options = { repo: Dir.pwd, write: false, json: false }
      parser = OptionParser.new do |o|
        o.banner = "Usage: bin/verdify route [--repo PATH] [--write] [--json]"
        o.on("--repo PATH", "Target Git repository") { |v| options[:repo] = v }
        o.on("--write", "Write route-decision YAML and Markdown") { options[:write] = true }
        o.on("--json", "Emit JSON instead of YAML") { options[:json] = true }
        o.on("-h", "--help") { puts o; return 0 }
      end
      parse_options(parser)
      repo = GitRepository.new(options[:repo])
      decision = build_route_decision(repo)
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

    def command_sprint
      subcommand = @argv.shift
      raise UsageError, "Usage: bin/verdify sprint init --id SPRINT-ID [--repo PATH]" unless subcommand == "init"

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

      base_ref = options[:base] || contract["baseline_sha"]
      resolved_base = repo.head_sha(base_ref)
      unless options[:allow_stale_baseline] || resolved_base == contract["baseline_sha"]
        raise UsageError, "resolved base #{resolved_base} does not match contract baseline #{contract['baseline_sha']}"
      end

      expire_stale_leases!(repo)
      conflict = all_leases(repo).find do |lease|
        lease["role"] == "worker" && lease["lane_id"] == options[:lane_id] && lease["status"] == "active"
      end
      raise UsageError, "lane already has active worker lease #{conflict['lease_id']}" if conflict

      branch = contract["branch"]
      path = options[:path] ? Pathname.new(options[:path]).expand_path : default_worktree_path(repo, options[:lane_id])
      raise UsageError, "worktree path already exists: #{path}" if path.exist?

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
        puts "DRY RUN"
        puts "git worktree add #{repo.branch_exists?(branch) ? '' : "-b #{branch} "}#{path} #{repo.branch_exists?(branch) ? branch : resolved_base}".strip
        puts "git worktree lock --reason #{Shellwords.escape("Verdify worker #{options[:lane_id]} session #{options[:session_id]}")} #{path}"
        puts JSON.pretty_generate(lease)
        return 0
      end

      repo.add_worktree(path: path, branch: branch, base: resolved_base)
      begin
        repo.lock_worktree(path, "Verdify worker #{options[:lane_id]} session #{options[:session_id]}")
        write_lease(repo, lease)
      rescue StandardError
        repo.unlock_worktree(path)
        repo.remove_worktree(path, force: true) if path.exist?
        raise
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
      contract_path = if worker_lease
                        Pathname.new(worker_lease["contract_path"])
                      else
                        find_contract_by_lane(repo, options[:lane_id])
                      end
      contract = load_and_validate_contract(contract_path)
      if worker_lease && worker_lease["session_id"] == options[:session_id]
        raise UsageError, "critic session must differ from worker session"
      end

      lease_id = "critic-#{options[:lane_id]}-#{Verdify.slug(options[:session_id], max: 24)}"
      existing = lease_path(repo, lease_id)
      raise UsageError, "critic lease already exists: #{lease_id}" if existing.exist? && load_json(existing)["status"] == "active"

      path = options[:path] ? Pathname.new(options[:path]).expand_path : default_review_path(repo, options[:lane_id], options[:session_id])
      raise UsageError, "review worktree path already exists: #{path}" if path.exist?
      branch = contract["branch"]
      repo.head_sha(branch)

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
        baseline_sha: repo.head_sha(branch),
        contract_path: contract_path,
        worktree_path: path,
        ttl_hours: contract.dig("lease_policy", "critic_ttl_hours") || 8
      )

      repo.add_worktree(path: path, branch: branch, base: branch, detach: true)
      begin
        repo.lock_worktree(path, "Verdify critic #{options[:lane_id]} session #{options[:session_id]}")
        write_lease(repo, lease)
      rescue StandardError
        repo.unlock_worktree(path)
        repo.remove_worktree(path, force: true) if path.exist?
        raise
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

    def build_route_decision(repo)
      root = repo.root.join(".agent-workflow")
      evidence = []
      missing = []
      open_gate_files = Dir[root.join("**/gates/*.yaml")].select do |path|
        begin
          Verdify.safe_load_yaml(path)["status"] == "open"
        rescue Error
          false
        end
      end
      open_gates = open_gate_files.map { |path| Pathname.new(path).relative_path_from(repo.root).to_s }

      unless open_gate_files.empty?
        gate = Verdify.safe_load_yaml(open_gate_files.first)
        skill, mode = route_for_gate(gate["type"])
        evidence << { "source" => Pathname.new(open_gate_files.first).relative_path_from(repo.root).to_s, "finding" => "open #{gate['type']} gate" }
        return route_hash(repo, "OPEN_GATE", skill, mode, "An open durable gate blocks normal progression.", evidence, missing, open_gates)
      end

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

      plans = Dir[root.join("sprints/*/sprint-plan.yaml")].map { |path| Pathname.new(path) }.sort_by(&:mtime).reverse
      if plans.empty?
        strategy_route = route_for_strategy(repo, root, evidence, missing, open_gates)
        return strategy_route if strategy_route

        return strategy_handoff_route(repo, root, evidence, missing, open_gates)
      end

      plan_path = plans.find do |path|
        plan = Verdify.safe_load_yaml(path)
        status_path = path.dirname.join("status.yaml")
        state = status_path.file? ? Verdify.safe_load_yaml(status_path)["state"] : nil
        !%w[complete cancelled].include?(plan["status"].to_s.downcase) && !%w[COMPLETE CANCELLED].include?(state)
      end
      unless plan_path
        strategy_route = route_for_strategy(repo, root, evidence, missing, open_gates)
        return strategy_route if strategy_route

        return strategy_handoff_route(repo, root, evidence, missing, open_gates)
      end

      plan = Verdify.safe_load_yaml(plan_path)
      sprint_id = plan["sprint_id"]
      evidence << { "source" => plan_path.relative_path_from(repo.root).to_s, "finding" => "active sprint #{sprint_id} has status #{plan['status']}" }
      unless plan.dig("approval", "status") == "approved"
        return route_hash(repo, "SPRINT_PLAN_UNAPPROVED", "sprint-planning", "plan-approval", "The complete sprint/lane transaction is not approved.", evidence, missing, open_gates)
      end

      contracts = Dir[plan_path.dirname.join("lanes/contracts/*.yaml")].map { |p| Pathname.new(p) }
      if contracts.empty?
        missing << ".agent-workflow/sprints/#{sprint_id}/lanes/contracts/<lane-id>.contract.yaml"
        return route_hash(repo, "LANE_TRANSACTION_INCOMPLETE", "sprint-planning", "lane-transaction", "The approved sprint has no lane contracts.", evidence, missing, open_gates)
      end

      contracts.each do |contract_path|
        contract = Verdify.safe_load_yaml(contract_path)
        lane_id = contract["lane_id"]
        closeout_path = plan_path.dirname.join("lanes/closeout/#{lane_id}.closeout.yaml")
        unless closeout_path.file?
          missing << closeout_path.relative_path_from(repo.root).to_s
          return route_hash(repo, "LANES_REQUIRE_ORCHESTRATION", "sprint-orchestrator", "dispatch-or-monitor", "At least one approved lane has no worker closeout.", evidence, missing, open_gates)
        end
        critic_path = plan_path.dirname.join("critic/#{lane_id}.critic.yaml")
        unless critic_path.file?
          missing << critic_path.relative_path_from(repo.root).to_s
          return route_hash(repo, "LANE_READY_FOR_CRITIC", "independent-critic", "lane-review", "A worker closeout awaits fresh independent review.", evidence, missing, open_gates)
        end
        critic = Verdify.safe_load_yaml(critic_path)
        unless %w[approve approve_with_risks].include?(critic["outcome"])
          return route_hash(repo, "CRITIC_ACTION_REQUIRED", "sprint-orchestrator", "gate-management", "A critic outcome requires fixes, blocking, or human review.", evidence, missing, open_gates)
        end
      end

      release_path = plan_path.dirname.join("release/release-verification.yaml")
      unless release_path.file?
        missing << release_path.relative_path_from(repo.root).to_s
        return route_hash(repo, "READY_FOR_INTEGRATION", "release-verification", "integration", "All required lanes have current critic approval; integration evidence is missing.", evidence, missing, open_gates)
      end
      release = Verdify.safe_load_yaml(release_path)
      unless release["status"] == "verified"
        return route_hash(repo, "DEPLOYMENT_NOT_VERIFIED", "release-verification", "deployment-verification", "The integrated revision has not been verified in the target environment.", evidence, missing, open_gates)
      end

      outcome_path = plan_path.dirname.join("outcome/outcome-review.yaml")
      unless outcome_path.file? && %w[accepted accepted_with_risks].include?(Verdify.safe_load_yaml(outcome_path)["decision"])
        missing << outcome_path.relative_path_from(repo.root).to_s
        return route_hash(repo, "OUTCOME_REVIEW_REQUIRED", "release-verification", "outcome-review", "Runtime verification exists but human outcome acceptance is missing or incomplete.", evidence, missing, open_gates)
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
      return nil if strategy["baseline_sha"].to_s == head

      route_hash(repo, "STATE_OF_UNION_STALE", "state-of-union", "strategy-refresh", "The approved strategy was assessed against a different repository baseline.", evidence, missing, open_gates)
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

      route_hash(repo, "STATE_OF_UNION_HANDOFF", skill, mode, reason, evidence, missing, open_gates)
    end

    def route_hash(repo, state, skill, mode, reason, evidence, missing, open_gates)
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

    def route_for_gate(type)
      case type
      when "project_definition" then ["project-definition", "gate-resolution"]
      when "architecture" then ["architecture-contracts", "gate-resolution"]
      when "strategy" then ["state-of-union", "gate-resolution"]
      when "plan_approval" then ["sprint-planning", "plan-approval"]
      when "deployment_approval", "incident", "outcome_acceptance" then ["release-verification", "gate-resolution"]
      else ["sprint-orchestrator", "gate-management"]
      end
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

    def write_lease(repo, lease)
      validate_hash!(lease, "lane-lease.schema.yaml", "lane lease")
      FileUtils.mkdir_p(lease_dir(repo))
      Verdify.atomic_write(lease_path(repo, lease["lease_id"]), JSON.pretty_generate(lease) + "\n")
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
      rescue ArgumentError
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
