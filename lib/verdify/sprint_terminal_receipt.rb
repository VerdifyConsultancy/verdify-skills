# frozen_string_literal: true

module Verdify
  class SprintTerminalReceipt
    RECOVERY_BUNDLE = "issue-135-recovery-v1"
    RECOVERY_SPRINT_IDS = %w[
      2026-07-10-autonomous-platform-strategy
      2026-07-10-delivery-controls
      2026-07-10-issue-135-terminal-authority
      2026-07-10-npm-oidc-recovery
      2026-07-10-publish-path-recovery
      2026-07-10-release-recovery
    ].freeze
    RECOVERY_CUTOVER_PULL_REQUEST = 213
    REQUIRED_CHECKS = {
      "validate" => ".github/workflows/validate.yml",
      "pull-request-policy" => ".github/workflows/policy.yml",
      "compliance / compliance" => ".github/workflows/compliance-selftest.yml",
      "delivery-policy" => ".github/workflows/delivery-gate.yml",
      "critic-gate" => ".github/workflows/delivery-gate.yml"
    }.freeze

    Result = Struct.new(:errors, :receipt, keyword_init: true) do
      def valid?
        errors.empty?
      end
    end

    def initialize(repo:, pull_request_loader: nil, check_run_loader: nil)
      @repo = repo.is_a?(GitRepository) ? repo : GitRepository.new(repo)
      @pull_request_loader = pull_request_loader || ->(number) { @repo.github_terminal_pull_request_evidence(number) }
      @check_run_loader = check_run_loader || ->(sha) { @repo.github_check_run_evidence(sha) }
      @pull_request_cache = {}
      @check_run_cache = {}
    end

    def write!(sprint_id:, controller_ref:, receipt_base_sha:, mode: "normal", generator: "verdify-controller")
      validate_mode!(sprint_id, mode)
      validate_sha!(receipt_base_sha, "receipt base")
      raise UsageError, "receipt base does not exist" unless @repo.commit_exists?(receipt_base_sha)
      expected_controller_ref = "controller/#{Verdify.slug(sprint_id)}"
      raise UsageError, "controller ref must be #{expected_controller_ref}" unless controller_ref == expected_controller_ref

      controller_head = resolve_controller_head(controller_ref)
      paths = self.class.paths(sprint_id)
      packet_path = self.class.packet_path(sprint_id)
      packet_commit = @repo.last_change_sha(packet_path, ref: controller_head)
      release_commit = @repo.last_change_sha(paths.fetch(:release), ref: controller_head)
      outcome_commit = @repo.last_change_sha(paths.fetch(:outcome), ref: controller_head)
      [packet_commit, release_commit, outcome_commit].each do |sha|
        raise CommandError, "controller evidence is missing P/R/O for #{sprint_id}" unless full_sha?(sha)
      end

      packet_bytes = @repo.file_at(packet_commit, packet_path)
      release_bytes = @repo.file_at(release_commit, paths.fetch(:release))
      outcome_bytes = @repo.file_at(outcome_commit, paths.fetch(:outcome))
      controller_plan_bytes = @repo.file_at(controller_head, paths.fetch(:plan))
      canonical_plan_bytes = @repo.file_at(receipt_base_sha, paths.fetch(:plan))
      unless controller_plan_bytes == canonical_plan_bytes
        raise CommandError, "controller sprint plan differs from the integrated reviewed plan"
      end
      plan = load_yaml_bytes(controller_plan_bytes, "sprint plan")
      packet = load_yaml_bytes(packet_bytes, "review packet")
      release = load_yaml_bytes(release_bytes, "release verification")
      outcome = load_yaml_bytes(outcome_bytes, "outcome review")
      validate_source_documents!(sprint_id, packet, release, outcome)
      validate_packet_identity!(packet, controller_ref)

      plan["status"] = "complete"
      status = {
        "schema_ref" => "status.schema.yaml",
        "kind" => "SprintStatus",
        "schema_version" => "1.0",
        "sprint_id" => sprint_id,
        "state" => "COMPLETE",
        "updated_at" => Verdify.utc_now,
        "active_lanes" => [],
        "blockers" => [],
        "next_action" => "Terminal receipt accepted on protected dev; rerun project-router."
      }
      plan_bytes = YAML.dump(plan)
      status_bytes = YAML.dump(status)
      lanes = build_lane_bindings(sprint_id, controller_head, packet, receipt_base_sha)
      expected_lane_ids = lanes.map { |lane| lane.fetch("lane_id") }.sort
      expected_issue_ids = lanes.flat_map { |lane| lane.fetch("issue_ids") }.uniq.sort
      expected_pull_requests = lanes.map { |lane| lane.fetch("pull_request") }.sort
      raise CommandError, "review packet lane scope does not match controller lanes" unless Array(packet.dig("scope", "lane_ids")).sort == expected_lane_ids
      raise CommandError, "review packet issue scope does not match controller lanes" unless Array(packet.dig("scope", "issue_ids")).sort == expected_issue_ids
      packet_pull_requests = Array(packet["pull_requests"]).filter_map { |item| item["identifier"].to_s[/(\d+)\z/, 1]&.to_i }.sort
      raise CommandError, "review packet pull request scope does not match controller lanes" unless packet_pull_requests == expected_pull_requests
      integrated_sha = release.fetch("integrated_sha")
      lanes.each do |lane|
        unless @repo.commit_exists?(integrated_sha) && @repo.ancestor?(lane.fetch("merge_commit_sha"), integrated_sha)
          raise CommandError, "verified integrated SHA does not contain lane #{lane.fetch('lane_id')} merge"
        end
      end
      receipt = {
        "schema_ref" => "sprint-terminal-receipt.schema.yaml",
        "kind" => "SprintTerminalReceipt",
        "schema_version" => "1.0",
        "sprint_id" => sprint_id,
        "mode" => mode,
        "recovery_bundle" => mode == "recovery" ? RECOVERY_BUNDLE : nil,
        "receipt_base_sha" => receipt_base_sha,
        "integration_branch" => "dev",
        "controller" => {
          "ref" => controller_ref,
          "head_sha" => controller_head,
          "packet_commit_sha" => packet_commit,
          "release_commit_sha" => release_commit,
          "outcome_commit_sha" => outcome_commit,
          "packet_path" => packet_path,
          "packet_sha256" => Digest::SHA256.hexdigest(packet_bytes),
          "release_sha256" => Digest::SHA256.hexdigest(release_bytes),
          "outcome_sha256" => Digest::SHA256.hexdigest(outcome_bytes)
        },
        "lanes" => lanes,
        "artifacts" => {
          "plan_sha256" => Digest::SHA256.hexdigest(plan_bytes),
          "status_sha256" => Digest::SHA256.hexdigest(status_bytes),
          "release_sha256" => Digest::SHA256.hexdigest(release_bytes),
          "outcome_sha256" => Digest::SHA256.hexdigest(outcome_bytes)
        },
        "terminal" => {
          "integrated_sha" => integrated_sha,
          "plan_status" => "complete",
          "status_state" => "COMPLETE",
          "release_status" => "verified",
          "outcome_decision" => outcome.fetch("decision")
        },
        "generated_at" => Verdify.utc_now,
        "generator" => generator
      }
      validate_artifact!(receipt, "sprint-terminal-receipt.schema.yaml", "terminal receipt")

      Verdify.atomic_write(@repo.root.join(paths.fetch(:plan)), plan_bytes)
      Verdify.atomic_write(@repo.root.join(paths.fetch(:status)), status_bytes)
      Verdify.atomic_write(@repo.root.join(paths.fetch(:release)), release_bytes)
      Verdify.atomic_write(@repo.root.join(paths.fetch(:outcome)), outcome_bytes)
      Verdify.atomic_write(@repo.root.join(paths.fetch(:receipt)), YAML.dump(receipt))
      receipt
    end

    def validate_local(receipt_path:, ref: "HEAD", expected_base_sha: nil, require_commit_shape: true)
      errors = []
      path = absolute_path(receipt_path)
      receipt = load_working_artifact(path, "sprint-terminal-receipt.schema.yaml", errors)
      return Result.new(errors: errors.uniq, receipt: receipt) unless receipt

      sprint_id = receipt["sprint_id"]
      paths = self.class.paths(sprint_id)
      expected_receipt = @repo.root.join(paths.fetch(:receipt))
      errors << "terminal receipt path must be #{paths.fetch(:receipt)}" unless path == expected_receipt
      errors << "receipt base does not match the pull request base" if expected_base_sha && receipt["receipt_base_sha"] != expected_base_sha
      validate_local_snapshot(receipt, paths, errors, ref: ref, require_commit_shape: require_commit_shape)
      Result.new(errors: errors.uniq, receipt: receipt)
    end

    def validate_full(receipt_path:, expected_base_sha:, expected_mode: nil)
      local = validate_local(
        receipt_path: receipt_path,
        ref: "HEAD",
        expected_base_sha: expected_base_sha,
        require_commit_shape: true
      )
      errors = local.errors.dup
      receipt = local.receipt
      return Result.new(errors: errors.uniq, receipt: receipt) unless receipt

      errors << "receipt mode must be #{expected_mode}" if expected_mode && receipt["mode"] != expected_mode
      receipt_commit = @repo.last_change_sha(self.class.paths(receipt["sprint_id"]).fetch(:receipt), ref: @repo.head_sha)
      errors << "receipt pull request head must equal the one direct-parent receipt commit" unless receipt_commit == @repo.head_sha
      validate_controller(receipt, errors)
      validate_live_lanes(receipt, errors)
      if receipt["mode"] == "recovery"
        begin
          cutover = pull_request_evidence(RECOVERY_CUTOVER_PULL_REQUEST)
          errors << "recovery base must be the merge commit of PR ##{RECOVERY_CUTOVER_PULL_REQUEST}" unless cutover["merged"] == true && cutover["merge_commit_sha"] == receipt["receipt_base_sha"]
        rescue Error, StandardError => e
          errors << "could not validate recovery cutover PR: #{e.message}"
        end
      end
      Result.new(errors: errors.uniq, receipt: receipt)
    end

    def terminal_at?(sprint_id, ref: "HEAD")
      receipt_path = self.class.paths(sprint_id).fetch(:receipt)
      return false unless tracked_at?(ref, receipt_path)

      receipt = load_yaml_at(ref, receipt_path, "terminal receipt")
      errors = []
      validate_artifact_document(receipt, "sprint-terminal-receipt.schema.yaml", errors, "terminal receipt")
      errors << "terminal receipt sprint_id does not match its directory" unless receipt["sprint_id"] == sprint_id
      receipt_paths = self.class.paths(sprint_id)
      validate_ref_snapshot(receipt, receipt_paths, errors, ref: ref)
      validate_committed_shape(receipt, receipt_paths, errors, ref: ref)
      errors.empty?
    rescue Error, CommandError
      false
    end

    def integrated_unterminated_sprints(ref: "HEAD")
      sprint_root = ".agent-workflow/sprints"
      plans = @repo.tracked_paths(ref: ref, pathspec: sprint_root).grep(%r{/sprint-plan\.yaml\z})
      plans.filter_map do |plan_path|
        sprint_id = plan_path.split("/")[-2]
        next if terminal_at?(sprint_id, ref: ref)

        plan = load_yaml_at(ref, plan_path, "sprint plan")
        next if legacy_terminal_plan?(plan_path, plan, ref)
        next if plan["status"] == "cancelled"
        lane_ids = Array(plan["lanes"]).map { |lane| lane["lane_id"] }
        next if lane_ids.empty?

        integrated = lane_ids.all? do |lane_id|
          critic_path = "#{sprint_root}/#{sprint_id}/critic/#{lane_id}.critic.yaml"
          next false unless tracked_at?(ref, critic_path)

          critic = load_yaml_at(ref, critic_path, "critic report")
          report_head = @repo.last_change_sha(critic_path, ref: ref)
          %w[approve approve_with_risks].include?(critic["outcome"]) &&
            full_sha?(report_head) && @repo.ancestor?(report_head, ref)
        end
        sprint_id if integrated
      end.sort
    end

    def receipt_required_for_terminal?(plan_path, ref: "HEAD")
      schema_path = "schemas/sprint-terminal-receipt.schema.yaml"
      return false unless tracked_at?(ref, schema_path)

      cutover = @repo.first_change_sha(schema_path, ref: ref)
      terminalized = @repo.last_change_sha(plan_path, ref: ref)
      return true unless full_sha?(cutover) && full_sha?(terminalized)

      terminalized == cutover || !@repo.ancestor?(terminalized, cutover)
    end

    def self.paths(sprint_id)
      root = ".agent-workflow/sprints/#{sprint_id}"
      {
        plan: "#{root}/sprint-plan.yaml",
        status: "#{root}/status.yaml",
        release: "#{root}/release/release-verification.yaml",
        outcome: "#{root}/outcome/outcome-review.yaml",
        receipt: "#{root}/terminal/terminal-receipt.yaml"
      }
    end

    def self.packet_path(sprint_id)
      ".agent-workflow/sprints/#{sprint_id}/review/review-inbox-packet.yaml"
    end

    def self.allowed_receipt_paths(sprint_ids)
      sprint_ids.flat_map { |sprint_id| paths(sprint_id).values }.uniq.sort
    end

    private

    def validate_mode!(sprint_id, mode)
      raise UsageError, "receipt mode must be normal or recovery" unless %w[normal recovery].include?(mode)
      return unless mode == "recovery"

      raise UsageError, "recovery mode is limited to #{RECOVERY_SPRINT_IDS.join(', ')}" unless RECOVERY_SPRINT_IDS.include?(sprint_id)
    end

    def resolve_controller_head(ref)
      expected = "controller/"
      raise UsageError, "controller ref must start with #{expected}" unless ref.to_s.start_with?(expected)
      if @repo.remote_url
        remote_head = @repo.remote_branch_sha(ref)
        raise CommandError, "remote controller branch does not exist: #{ref}" unless remote_head
        fetched_head = @repo.fetch_branch_head(ref)
        raise CommandError, "controller branch changed while it was fetched" unless fetched_head == remote_head
        return fetched_head
      end

      local_ref = "refs/heads/#{ref}"
      return @repo.head_sha(local_ref) if @repo.commit_exists?(local_ref)

      raise CommandError, "controller branch does not exist: #{ref}"
    end

    def build_lane_bindings(sprint_id, controller_head, packet, receipt_base_sha)
      sprint_root = ".agent-workflow/sprints/#{sprint_id}"
      contract_paths = @repo.tracked_paths(ref: receipt_base_sha, pathspec: "#{sprint_root}/lanes/contracts").grep(/\.ya?ml\z/)
      raise CommandError, "integrated base has no lane contracts for #{sprint_id}" if contract_paths.empty?

      submissions = Array(packet.dig("traceability", "review_submissions"))
      contract_paths.map do |contract_path|
        contract = load_yaml_at(receipt_base_sha, contract_path, "lane contract")
        lane_id = contract.fetch("lane_id")
        closeout_path = "#{sprint_root}/lanes/closeout/#{lane_id}.closeout.yaml"
        critic_path = "#{sprint_root}/critic/#{lane_id}.critic.yaml"
        closeout = load_yaml_at(receipt_base_sha, closeout_path, "lane closeout")
        critic = load_yaml_at(receipt_base_sha, critic_path, "critic report")
        submission = submissions.find { |item| item["pull_request"] == critic["pull_request"] }
        raise CommandError, "review packet has no submission for PR ##{critic['pull_request']}" unless submission

        {
          contract_path => submission.fetch("review_submission_head_sha"),
          closeout_path => submission.fetch("review_submission_head_sha"),
          critic_path => submission.fetch("review_submission_head_sha")
        }.each do |path, reviewed_head|
          controller_bytes = @repo.file_at(controller_head, path)
          reviewed_bytes = @repo.file_at(reviewed_head, path)
          unless controller_bytes == reviewed_bytes
            raise CommandError, "controller lane artifact differs from canonical reviewed head: #{path}"
          end
        end

        pull = pull_request_evidence(critic.fetch("pull_request"))
        unless pull["merged"] == true && pull["state"].to_s.downcase == "merged"
          raise CommandError, "PR ##{critic['pull_request']} is not merged"
        end
        merge_sha = pull["merge_commit_sha"].to_s
        unless full_sha?(merge_sha) && @repo.commit_exists?(merge_sha) && @repo.ancestor?(merge_sha, receipt_base_sha)
          raise CommandError, "PR ##{critic['pull_request']} merge is not contained in the receipt base"
        end

        working_root = @repo.root.join(sprint_root)
        lane_validator = LaneReviewValidator.new(
          repo: @repo,
          contract_path: working_root.join("lanes/contracts/#{lane_id}.contract.yaml"),
          closeout_path: working_root.join("lanes/closeout/#{lane_id}.closeout.yaml"),
          critic_path: working_root.join("critic/#{lane_id}.critic.yaml")
        )
        chain = lane_validator.validate_critic(tip_sha: submission.fetch("review_submission_head_sha"))
        status = lane_validator.validate_critic_status(
          result: chain,
          pull_request_head_sha: submission.fetch("review_submission_head_sha")
        )
        raise CommandError, "lane #{lane_id} review chain is invalid: #{status.errors.join('; ')}" unless status.valid?

        {
          "lane_id" => chain.contract.fetch("lane_id"),
          "issue_ids" => chain.contract.fetch("issue_ids"),
          "branch" => chain.contract.fetch("branch"),
          "pull_request" => chain.critic.fetch("pull_request"),
          "dispatch_head_sha" => chain.dispatch_head_sha,
          "implementation_head_sha" => chain.implementation_head_sha,
          "evidence_head_sha" => chain.evidence_head_sha,
          "critic_report_head_sha" => chain.critic_report_head_sha,
          "merge_commit_sha" => merge_sha
        }
      end.sort_by { |lane| lane.fetch("lane_id") }
    end

    def validate_source_documents!(sprint_id, packet, release, outcome)
      validate_artifact!(packet, "review-inbox-packet.schema.yaml", "review packet")
      validate_artifact!(release, "release-verification.schema.yaml", "release verification")
      validate_artifact!(outcome, "outcome-review.schema.yaml", "outcome review")
      raise CommandError, "review packet scope does not match #{sprint_id}" unless packet.dig("scope", "sprint_id") == sprint_id
      unless %w[ready approved].include?(packet["status"]) && packet.dig("evidence_completeness", "verdict") == "complete" && packet.dig("recommendation", "outcome") == "approve"
        raise CommandError, "review packet is not approved and complete"
      end
      raise CommandError, "release verification is not verified for #{sprint_id}" unless release["sprint_id"] == sprint_id && release["status"] == "verified"
      unless outcome["sprint_id"] == sprint_id && %w[accepted accepted_with_risks].include?(outcome["decision"])
        raise CommandError, "outcome review is not accepted for #{sprint_id}"
      end
    end

    def validate_packet_identity!(packet, controller_ref)
      expected_repository = @repo.github_slug
      if expected_repository && packet.dig("traceability", "repository") != expected_repository
        raise CommandError, "review packet repository does not match the receipt repository"
      end
      raise CommandError, "review packet base_ref must be dev" unless packet.dig("traceability", "base_ref") == "dev"
      unless packet.dig("traceability", "head_ref") == controller_ref
        raise CommandError, "review packet head_ref does not match the controller ref"
      end
    end

    def validate_local_snapshot(receipt, paths, errors, ref:, require_commit_shape:)
      sprint_id = receipt["sprint_id"]
      errors << "receipt integration branch must be dev" unless receipt["integration_branch"] == "dev"
      if receipt["mode"] == "recovery" && !RECOVERY_SPRINT_IDS.include?(sprint_id)
        errors << "recovery receipt names an unlisted sprint"
      end
      validate_ref_or_working_artifacts(receipt, paths, errors)

      base = receipt["receipt_base_sha"].to_s
      integrated = receipt.dig("terminal", "integrated_sha").to_s
      errors << "receipt base does not exist" unless full_sha?(base) && @repo.commit_exists?(base)
      errors << "integrated SHA does not exist" unless full_sha?(integrated) && @repo.commit_exists?(integrated)
      if @repo.commit_exists?(integrated) && @repo.commit_exists?(base) && !@repo.ancestor?(integrated, base)
        errors << "integrated SHA must be contained in the receipt base"
      end
      errors << "receipt base must be an ancestor of #{ref}" if @repo.commit_exists?(base) && @repo.commit_exists?(ref) && !@repo.ancestor?(base, ref)

      validate_lane_snapshots(receipt, errors, ref: ref)
      return unless require_commit_shape && @repo.commit_exists?(ref)

      receipt_commit = @repo.last_change_sha(paths.fetch(:receipt), ref: ref)
      if receipt_commit.nil?
        errors << "terminal receipt is not committed"
        return
      end
      paths.each_value do |artifact_path|
        errors << "terminal artifacts must share one receipt commit" unless @repo.last_change_sha(artifact_path, ref: ref) == receipt_commit
      end
      parents = @repo.commit_parents(receipt_commit)
      errors << "receipt commit must be linear and based on the exact recorded dev head" unless parents == [base]
      receipt_sprints = receipt["mode"] == "recovery" ? RECOVERY_SPRINT_IDS : [sprint_id]
      unauthorized = @repo.changed_paths(receipt_commit) - self.class.allowed_receipt_paths(receipt_sprints)
      errors << "receipt commit changes unauthorized paths: #{unauthorized.join(', ')}" unless unauthorized.empty?
    rescue CommandError => e
      errors << "could not validate terminal receipt history: #{e.message}"
    end

    def validate_ref_or_working_artifacts(receipt, paths, errors)
      documents = {}
      paths.each do |kind, relative|
        next if kind == :receipt
        path = @repo.root.join(relative)
        unless path.file?
          errors << "terminal artifact is missing: #{relative}"
          next
        end
        bytes = path.binread
        expected_digest = receipt.dig("artifacts", "#{kind}_sha256")
        errors << "#{kind} artifact digest does not match the receipt" unless Digest::SHA256.hexdigest(bytes) == expected_digest
        documents[kind] = load_yaml_bytes(bytes, kind.to_s, errors)
      end
      validate_terminal_documents(receipt, documents, errors)
    end

    def validate_ref_snapshot(receipt, paths, errors, ref:)
      documents = {}
      paths.each do |kind, relative|
        next if kind == :receipt
        unless tracked_at?(ref, relative)
          errors << "terminal artifact is missing at #{ref}: #{relative}"
          next
        end
        bytes = @repo.file_at(ref, relative)
        expected_digest = receipt.dig("artifacts", "#{kind}_sha256")
        errors << "#{kind} artifact digest does not match the receipt" unless Digest::SHA256.hexdigest(bytes) == expected_digest
        documents[kind] = load_yaml_bytes(bytes, kind.to_s, errors)
      end
      validate_terminal_documents(receipt, documents, errors)
      base = receipt["receipt_base_sha"].to_s
      integrated = receipt.dig("terminal", "integrated_sha").to_s
      errors << "receipt base must be an ancestor of #{ref}" unless @repo.commit_exists?(base) && @repo.ancestor?(base, ref)
      errors << "integrated SHA must be contained in the receipt base" unless @repo.commit_exists?(integrated) && @repo.commit_exists?(base) && @repo.ancestor?(integrated, base)
    end

    def validate_committed_shape(receipt, paths, errors, ref:)
      receipt_commit = @repo.last_change_sha(paths.fetch(:receipt), ref: ref)
      unless full_sha?(receipt_commit)
        errors << "terminal receipt is not committed"
        return
      end
      paths.each_value do |artifact_path|
        errors << "terminal artifacts must share one receipt commit" unless @repo.last_change_sha(artifact_path, ref: ref) == receipt_commit
      end
      base = receipt["receipt_base_sha"].to_s
      errors << "receipt commit must be linear and based on the exact recorded dev head" unless @repo.commit_parents(receipt_commit) == [base]
      receipt_sprints = receipt["mode"] == "recovery" ? RECOVERY_SPRINT_IDS : [receipt["sprint_id"]]
      unauthorized = @repo.changed_paths(receipt_commit) - self.class.allowed_receipt_paths(receipt_sprints)
      errors << "receipt commit changes unauthorized paths: #{unauthorized.join(', ')}" unless unauthorized.empty?
    rescue CommandError => e
      errors << "could not validate committed receipt shape: #{e.message}"
    end

    def validate_terminal_documents(receipt, documents, errors)
      sprint_id = receipt["sprint_id"]
      schemas = { plan: "sprint-plan.schema.yaml", status: "status.schema.yaml", release: "release-verification.schema.yaml", outcome: "outcome-review.schema.yaml" }
      documents.each { |kind, document| validate_artifact_document(document, schemas.fetch(kind), errors, kind.to_s) }
      plan = documents[:plan]
      status = documents[:status]
      release = documents[:release]
      outcome = documents[:outcome]
      errors << "terminal plan must match the receipt sprint and be complete" unless plan && plan["sprint_id"] == sprint_id && plan["status"] == receipt.dig("terminal", "plan_status")
      errors << "terminal status must match the receipt sprint and be COMPLETE" unless status && status["sprint_id"] == sprint_id && status["state"] == receipt.dig("terminal", "status_state")
      errors << "release verification must match the receipt" unless release && release["sprint_id"] == sprint_id && release["status"] == receipt.dig("terminal", "release_status") && release["integrated_sha"] == receipt.dig("terminal", "integrated_sha")
      errors << "outcome review must match the receipt" unless outcome && outcome["sprint_id"] == sprint_id && outcome["decision"] == receipt.dig("terminal", "outcome_decision")
    end

    def validate_lane_snapshots(receipt, errors, ref:)
      sprint_id = receipt["sprint_id"]
      Array(receipt["lanes"]).each do |lane|
        lane_id = lane["lane_id"]
        root = @repo.root.join(".agent-workflow/sprints/#{sprint_id}")
        validator = LaneReviewValidator.new(
          repo: @repo,
          contract_path: root.join("lanes/contracts/#{lane_id}.contract.yaml"),
          closeout_path: root.join("lanes/closeout/#{lane_id}.closeout.yaml"),
          critic_path: root.join("critic/#{lane_id}.critic.yaml")
        )
        result = validator.validate_critic(tip_sha: lane["critic_report_head_sha"])
        errors.concat(result.errors.map { |error| "#{lane_id}: #{error}" })
        errors << "#{lane_id}: implementation head does not match receipt" unless result.implementation_head_sha == lane["implementation_head_sha"]
        errors << "#{lane_id}: dispatch head does not match receipt" unless result.dispatch_head_sha == lane["dispatch_head_sha"]
        errors << "#{lane_id}: evidence head does not match receipt" unless result.evidence_head_sha == lane["evidence_head_sha"]
        errors << "#{lane_id}: critic report head does not match receipt" unless result.critic_report_head_sha == lane["critic_report_head_sha"]
        errors << "#{lane_id}: issue IDs do not match the reviewed contract" unless result.contract && result.contract["issue_ids"] == lane["issue_ids"]
        errors << "#{lane_id}: branch does not match the reviewed contract" unless result.contract && result.contract["branch"] == lane["branch"]
        errors << "#{lane_id}: pull request does not match the reviewed critic report" unless result.critic && result.critic["pull_request"] == lane["pull_request"]
        merge_sha = lane["merge_commit_sha"].to_s
        base = receipt["receipt_base_sha"].to_s
        integrated = receipt.dig("terminal", "integrated_sha").to_s
        errors << "#{lane_id}: merge commit is not contained in the receipt base" unless @repo.commit_exists?(merge_sha) && @repo.commit_exists?(base) && @repo.ancestor?(merge_sha, base)
        errors << "#{lane_id}: verified integrated SHA does not contain the lane merge" unless @repo.commit_exists?(merge_sha) && @repo.commit_exists?(integrated) && @repo.ancestor?(merge_sha, integrated)
      end
    rescue CommandError => e
      errors << "could not validate lane receipt bindings at #{ref}: #{e.message}"
    end

    def validate_controller(receipt, errors)
      sprint_id = receipt["sprint_id"]
      paths = self.class.paths(sprint_id)
      controller = receipt["controller"] || {}
      expected_ref = "controller/#{Verdify.slug(sprint_id)}"
      errors << "controller ref must be #{expected_ref}" unless controller["ref"] == expected_ref
      head = resolve_controller_head(controller["ref"])
      errors << "controller head changed after receipt generation" unless head == controller["head_sha"] && head == controller["outcome_commit_sha"]
      p_sha = controller["packet_commit_sha"]
      r_sha = controller["release_commit_sha"]
      o_sha = controller["outcome_commit_sha"]
      unless [p_sha, r_sha, o_sha].all? { |sha| full_sha?(sha) && @repo.commit_exists?(sha) }
        errors << "controller P/R/O commits are unavailable"
        return
      end
      errors << "controller P/R/O ancestry is invalid" unless @repo.ancestor?(p_sha, r_sha) && @repo.ancestor?(r_sha, o_sha)
      errors << "packet commit P must change only the review packet" unless @repo.changed_paths(p_sha) == [controller["packet_path"]]
      errors << "release commit R must change only release verification" unless @repo.changed_paths(r_sha) == [paths.fetch(:release)]
      errors << "outcome commit O must change only outcome review" unless @repo.changed_paths(o_sha) == [paths.fetch(:outcome)]
      allowed_suffix = [paths.fetch(:release), paths.fetch(:outcome), paths.fetch(:status)]
      @repo.commits_between(p_sha, o_sha).each do |commit|
        errors << "controller P..O suffix contains merge commit #{commit}" unless @repo.commit_parents(commit).length == 1
        unauthorized = @repo.changed_paths(commit) - allowed_suffix
        errors << "controller P..O commit #{commit} changes unauthorized paths: #{unauthorized.join(', ')}" unless unauthorized.empty?
      end
      errors << "controller packet last-change commit does not match P" unless @repo.last_change_sha(controller["packet_path"], ref: head) == p_sha
      errors << "controller release last-change commit does not match R" unless @repo.last_change_sha(paths.fetch(:release), ref: head) == r_sha
      errors << "controller outcome last-change commit does not match O" unless @repo.last_change_sha(paths.fetch(:outcome), ref: head) == o_sha

      packet_bytes = @repo.file_at(p_sha, controller["packet_path"])
      release_bytes = @repo.file_at(r_sha, paths.fetch(:release))
      outcome_bytes = @repo.file_at(o_sha, paths.fetch(:outcome))
      errors << "controller packet digest does not match receipt" unless Digest::SHA256.hexdigest(packet_bytes) == controller["packet_sha256"]
      errors << "controller release digest does not match receipt" unless Digest::SHA256.hexdigest(release_bytes) == controller["release_sha256"]
      errors << "controller outcome digest does not match receipt" unless Digest::SHA256.hexdigest(outcome_bytes) == controller["outcome_sha256"]
      packet = load_yaml_bytes(packet_bytes, "review packet", errors)
      release = load_yaml_bytes(release_bytes, "release verification", errors)
      outcome = load_yaml_bytes(outcome_bytes, "outcome review", errors)
      validate_source_documents!(sprint_id, packet, release, outcome)
      expected_lanes = Array(receipt["lanes"])
      expected_repository = @repo.github_slug
      errors << "review packet repository does not match the receipt repository" if expected_repository && packet.dig("traceability", "repository") != expected_repository
      errors << "review packet base_ref must be dev" unless packet.dig("traceability", "base_ref") == "dev"
      errors << "review packet head_ref does not match the controller ref" unless packet.dig("traceability", "head_ref") == controller["ref"]
      errors << "review packet lane scope does not match receipt" unless Array(packet.dig("scope", "lane_ids")).sort == expected_lanes.map { |lane| lane["lane_id"] }.sort
      errors << "review packet issue scope does not match receipt" unless Array(packet.dig("scope", "issue_ids")).sort == expected_lanes.flat_map { |lane| lane["issue_ids"] }.uniq.sort
      packet_pull_requests = Array(packet["pull_requests"]).filter_map { |item| item["identifier"].to_s[/(\d+)\z/, 1]&.to_i }.sort
      errors << "review packet pull request scope does not match receipt" unless packet_pull_requests == expected_lanes.map { |lane| lane["pull_request"] }.sort
      submissions = Array(packet.dig("traceability", "review_submissions"))
      expected_lanes.each do |lane|
        submission = submissions.find { |item| item["pull_request"] == lane["pull_request"] }
        errors << "review packet submission does not bind #{lane['lane_id']} to exact S" unless submission && submission["review_submission_head_sha"] == lane["critic_report_head_sha"]
      end
    rescue Error, CommandError => e
      errors << "controller evidence validation failed: #{e.message}"
    end

    def validate_live_lanes(receipt, errors)
      Array(receipt["lanes"]).each do |lane|
        pull = pull_request_evidence(lane["pull_request"])
        unless pull["merged"] == true && pull["state"].to_s.downcase == "merged"
          errors << "PR ##{lane['pull_request']} is not merged"
          next
        end
        errors << "PR ##{lane['pull_request']} head does not match exact S" unless pull["head_sha"] == lane["critic_report_head_sha"]
        errors << "PR ##{lane['pull_request']} branch/base identity is wrong" unless pull["head_ref"] == lane["branch"] && pull["base_ref"] == "dev"
        errors << "PR ##{lane['pull_request']} merge commit changed" unless pull["merge_commit_sha"] == lane["merge_commit_sha"]
        checks = check_run_evidence(lane["critic_report_head_sha"])
        validate_trusted_checks(checks, lane["pull_request"], lane["critic_report_head_sha"], errors)
      rescue Error, StandardError => e
        errors << "could not validate PR ##{lane['pull_request']}: #{e.message}"
      end
    end

    def validate_trusted_checks(checks, pull_request, expected_head, errors)
      REQUIRED_CHECKS.each do |name, workflow_path|
        matches = Array(checks).select { |check| check["name"] == name }
        latest = matches.max_by do |check|
          observed_at = %w[created_at started_at completed_at].filter_map do |field|
            value = check[field].to_s
            value unless value.empty?
          end.max.to_s
          [observed_at, check["id"].to_i]
        end
        trusted = latest &&
                  latest["status"].to_s.downcase == "completed" &&
                  latest["conclusion"].to_s.downcase == "success" &&
                  latest["app_slug"] == "github-actions" &&
                  latest["workflow_path"] == workflow_path &&
                  latest["workflow_event"] == "pull_request" &&
                  latest["workflow_head_sha"] == expected_head
        errors << "PR ##{pull_request} requires a uniquely ordered latest trusted #{name} check" unless trusted
      end
    end

    def load_working_artifact(path, schema_name, errors)
      unless path.file?
        errors << "artifact does not exist: #{path}"
        return nil
      end
      document = SchemaValidator.load_document(path)
      validate_artifact_document(document, schema_name, errors, path.basename.to_s)
      document
    rescue Error => e
      errors << e.message
      nil
    end

    def validate_artifact!(document, schema_name, label)
      errors = []
      validate_artifact_document(document, schema_name, errors, label)
      raise CommandError, "#{label} is invalid: #{errors.join('; ')}" unless errors.empty?
    end

    def validate_artifact_document(document, schema_name, errors, label)
      schema = SchemaValidator.load_document(Verdify::ROOT.join("schemas", schema_name))
      errors.concat(SchemaValidator.new.validate(document, schema).map { |error| "#{label}: #{error}" })
      errors.concat(SemanticValidator.validate(document).map { |error| "#{label}: #{error}" })
    end

    def load_yaml_at(ref, path, label)
      load_yaml_bytes(@repo.file_at(ref, path), label)
    rescue CommandError => e
      raise CommandError, "#{label} is unavailable at #{ref}: #{e.message}"
    end

    def load_yaml_bytes(bytes, label, errors = nil)
      YAML.safe_load(bytes, permitted_classes: [], aliases: false) || {}
    rescue Psych::Exception => e
      message = "#{label} YAML is invalid: #{e.message}"
      errors ? (errors << message; {}) : (raise CommandError, message)
    end

    def tracked_at?(ref, path)
      @repo.git("cat-file", "-e", "#{ref}:#{path}", allow_failure: true).last.success?
    end

    def pull_request_evidence(number)
      @pull_request_cache[number.to_i] ||= @pull_request_loader.call(number)
    end

    def check_run_evidence(sha)
      @check_run_cache[sha.to_s] ||= @check_run_loader.call(sha)
    end

    def legacy_terminal_plan?(plan_path, plan, ref)
      return false unless plan["status"] == "complete"
      status_path = plan_path.sub(%r{/sprint-plan\.yaml\z}, "/status.yaml")
      return false unless tracked_at?(ref, status_path)
      status = load_yaml_at(ref, status_path, "sprint status")
      return false unless status["state"] == "COMPLETE"
      schema_path = "schemas/sprint-terminal-receipt.schema.yaml"
      return true unless tracked_at?(ref, schema_path)

      cutover = @repo.first_change_sha(schema_path, ref: ref)
      terminalized = @repo.last_change_sha(plan_path, ref: ref)
      full_sha?(cutover) && full_sha?(terminalized) && terminalized != cutover && @repo.ancestor?(terminalized, cutover)
    end

    def absolute_path(path)
      candidate = Pathname.new(path)
      expanded = candidate.absolute? ? candidate.expand_path : @repo.root.join(candidate).expand_path
      expanded.exist? ? expanded.realpath : expanded
    end

    def full_sha?(value)
      value.to_s.match?(/\A[0-9a-f]{40}\z/i)
    end

    def validate_sha!(value, label)
      raise UsageError, "#{label} must be a full 40-character commit SHA" unless full_sha?(value)
    end
  end
end
