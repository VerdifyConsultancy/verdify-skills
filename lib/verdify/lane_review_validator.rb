# frozen_string_literal: true

module Verdify
  class LaneReviewValidator
    APPROVING_OUTCOMES = %w[approve approve_with_risks].freeze
    # Evidence categories that cannot exist while the worker closeout is being
    # written: critic review, CI checks, integration/merge, deployment, outcome
    # acceptance, and terminal receipts all happen in later lifecycle phases.
    # Evidence IDs recorded in the closeout's own validation_results are exempt
    # because they identify commands the worker itself executed and recorded.
    FUTURE_PHASE_EVIDENCE_PATTERN =
      /\b(critic|ci|check|checks|integration|integrated|merge|merged|deploy|deployment|deployed|outcome|receipt|github)\b/i

    Result = Struct.new(
      :errors,
      :contract,
      :closeout,
      :critic,
      :implementation_head_sha,
      :evidence_head_sha,
      :critic_report_head_sha,
      :dispatch_head_sha,
      keyword_init: true
    ) do
      def valid?
        errors.empty?
      end
    end

    def initialize(repo:, contract_path:, closeout_path:, critic_path: nil)
      @repo = repo.is_a?(GitRepository) ? repo : GitRepository.new(repo)
      @contract_path = absolute_path(contract_path)
      @closeout_path = absolute_path(closeout_path)
      @critic_path = critic_path && absolute_path(critic_path)
    end

    def validate_closeout(evidence_head_sha:)
      errors = []
      contract = load_artifact(@contract_path, "lane-contract.schema.yaml", errors)
      closeout = load_artifact(@closeout_path, "lane-closeout.schema.yaml", errors)
      contract_rel = relative_path(@contract_path, errors)
      closeout_rel = relative_path(@closeout_path, errors)
      errors << "closeout status must be ready_for_critic" if closeout && closeout["status"] != "ready_for_critic"

      if contract && closeout
        expected = contract_rel&.dirname&.parent&.join("closeout/#{contract['lane_id']}.closeout.yaml")
        errors << "closeout path must be #{expected}" if expected && closeout_rel != expected
        unless %w[approved dispatched changes_requested].include?(contract["status"]) && contract.dig("approval", "status") == "approved"
          errors << "lane contract must be approved for execution"
        end
        compare_identity(contract, closeout, errors)
        errors << "closeout issue_ids must match lane contract" unless closeout["issue_ids"] == contract["issue_ids"]
        errors << "closeout baseline_sha must match lane contract" unless closeout["baseline_sha"] == contract["baseline_sha"]
        validate_closeout_claims(contract, closeout, errors)
      end

      implementation_head = closeout && closeout["implementation_head_sha"]
      evidence_head = evidence_head_sha.to_s
      baseline = closeout && closeout["baseline_sha"]
      dispatch_head = nil
      errors << "evidence head must be a full 40-character commit SHA" unless full_sha?(evidence_head)

      if implementation_head && evidence_head && closeout_rel
        validate_commit(baseline, "baseline", errors)
        validate_commit(implementation_head, "implementation", errors)
        validate_commit(evidence_head, "evidence", errors)
        if contract_rel && @repo.commit_exists?(implementation_head)
          begin
            committed_contract = @repo.file_at(implementation_head, contract_rel)
            errors << "closeout contract_hash does not match the contract at implementation_head_sha" unless closeout["contract_hash"] == Digest::SHA256.hexdigest(committed_contract)
            errors << "working lane contract does not match implementation_head_sha" unless @contract_path.binread == committed_contract
          rescue CommandError => e
            errors << "could not read lane contract at implementation head: #{e.message}"
          end
        end
        if commits_available?(baseline, implementation_head) && !@repo.ancestor?(baseline, implementation_head)
          errors << "baseline head must be an ancestor of implementation head"
        end
        dispatch_head = validate_dispatch_snapshot(baseline, implementation_head, contract_rel, errors) if contract_rel
        validate_linear_suffix(implementation_head, evidence_head, closeout_rel.to_s, "worker evidence", errors)
        validate_file_snapshot(@closeout_path, evidence_head, closeout_rel, "closeout", errors)
      end

      Result.new(
        errors: errors,
        contract: contract,
        closeout: closeout,
        critic: nil,
        implementation_head_sha: implementation_head,
        evidence_head_sha: evidence_head,
        critic_report_head_sha: nil,
        dispatch_head_sha: dispatch_head
      )
    end

    def validate_critic(tip_sha: "HEAD")
      errors = []
      critic = load_artifact(@critic_path, "critic-report.schema.yaml", errors)
      evidence_head = critic && critic["evidence_head_sha"]
      closeout_result = validate_closeout(evidence_head_sha: evidence_head)
      errors.concat(closeout_result.errors)
      contract = closeout_result.contract
      closeout = closeout_result.closeout
      critic_rel = relative_path(@critic_path, errors)
      closeout_rel = relative_path(@closeout_path, errors)

      if contract && critic
        expected = relative_path(@contract_path, errors)&.dirname&.parent&.parent&.join("critic/#{contract['lane_id']}.critic.yaml")
        errors << "critic path must be #{expected}" if expected && critic_rel != expected
        compare_identity(contract, critic, errors)
        validate_critic_assessment(contract, critic, errors)
      end

      if closeout && critic
        errors << "critic pull_request must match closeout pull_request" unless critic["pull_request"] == closeout["pull_request"]
        errors << "critic worker_agent must match closeout worker_agent" unless critic["worker_agent"] == closeout["worker_agent"]
        errors << "critic worker_session_id must match closeout worker_session_id" unless critic["worker_session_id"] == closeout["worker_session_id"]
        errors << "critic agent must differ from worker agent" if critic["critic_agent"] == closeout["worker_agent"]
        errors << "critic session must differ from worker session" if critic["critic_session_id"] == closeout["worker_session_id"]
        unless critic["implementation_head_sha"] == closeout["implementation_head_sha"]
          errors << "critic implementation_head_sha must match closeout implementation_head_sha"
        end
        errors << "critic reviewed_head_sha must equal evidence_head_sha" unless critic["reviewed_head_sha"] == critic["evidence_head_sha"]
        errors << "critic closeout_path must identify the canonical closeout" unless closeout_rel && critic["closeout_path"] == closeout_rel.to_s
        if closeout_rel && full_sha?(evidence_head) && @repo.commit_exists?(evidence_head)
          begin
            digest = Digest::SHA256.hexdigest(@repo.file_at(evidence_head, closeout_rel))
            errors << "critic closeout_sha256 does not match the closeout reviewed at evidence_head_sha" unless critic["closeout_sha256"] == digest
          rescue CommandError => e
            errors << "could not read closeout at evidence head: #{e.message}"
          end
        end
      end

      report_head = critic_rel && @repo.last_change_sha(critic_rel, ref: tip_sha)
      if report_head.nil?
        errors << "critic report is not committed at #{tip_sha}"
      elsif evidence_head && critic_rel
        validate_linear_suffix(evidence_head, report_head, critic_rel.to_s, "critic evidence", errors)
        validate_file_snapshot(@critic_path, report_head, critic_rel, "critic report", errors)
        if closeout_rel
          last_closeout_change = @repo.last_change_sha(closeout_rel, ref: tip_sha)
          errors << "closeout changed after evidence_head_sha" unless last_closeout_change == evidence_head
        end
      end

      Result.new(
        errors: errors.uniq,
        contract: contract,
        closeout: closeout,
        critic: critic,
        implementation_head_sha: closeout_result.implementation_head_sha,
        evidence_head_sha: evidence_head,
        critic_report_head_sha: report_head,
        dispatch_head_sha: closeout_result.dispatch_head_sha
      )
    end

    def validate_submission(result:, review_submission_head_sha:, expected_reviewer_login:, expected_reviewer_id:, reviewer_permission:, pull_request_head_sha:, pull_request_author:, pull_request_author_id:, submitted_reviews:)
      errors = result.errors.dup
      submission = review_submission_head_sha.to_s
      pull_head = pull_request_head_sha.to_s
      report_head = result.critic_report_head_sha.to_s
      errors << "review submission head must be a full 40-character commit SHA" unless full_sha?(submission)
      errors << "live pull request head must be a full 40-character commit SHA" unless full_sha?(pull_head)
      errors << "review submission head must equal the critic report head" unless submission == report_head
      errors << "live pull request head must equal the critic report head" unless pull_head == report_head
      expected_reviewer = expected_reviewer_login.to_s.downcase
      expected_reviewer_id = expected_reviewer_id.to_i
      effective_history = Array(submitted_reviews).select do |review|
        %w[APPROVED CHANGES_REQUESTED DISMISSED].include?(review["state"].to_s.upcase)
      end
      latest_by_reviewer = effective_history.group_by { |review| review["reviewer"].to_s.downcase }.transform_values do |reviews|
        reviews.max_by { |review| [review["submitted_at"].to_s, review["id"].to_s] }
      end
      latest_review = latest_by_reviewer[expected_reviewer]
      unresolved_change_requests = latest_by_reviewer.values.select do |review|
        review["state"].to_s.upcase == "CHANGES_REQUESTED"
      end
      review_is_current = latest_review &&
                          latest_review["state"].to_s.upcase == "APPROVED" &&
                          latest_review["commit_id"] == report_head
      unless review_is_current
        errors << "no commit-bound GitHub review was submitted for the critic report head"
      end
      unless unresolved_change_requests.empty?
        reviewers = unresolved_change_requests.map { |review| review["reviewer"].to_s }.reject(&:empty?).uniq.sort
        suffix = reviewers.empty? ? "" : ": #{reviewers.join(', ')}"
        errors << "an effective change-request review remains unresolved#{suffix}"
      end
      author = pull_request_author.to_s.downcase
      independent_actor = !expected_reviewer.empty? &&
                          expected_reviewer != author &&
                          expected_reviewer_id.positive? &&
                          expected_reviewer_id != pull_request_author_id.to_i
      authorized_actor = %w[admin maintain].include?(reviewer_permission.to_s.downcase)
      unless independent_actor && authorized_actor && review_is_current
        errors << "commit-bound GitHub approval must be submitted by an independent repository admin or maintainer"
      end

      Result.new(
        errors: errors.uniq,
        contract: result.contract,
        closeout: result.closeout,
        critic: result.critic,
        implementation_head_sha: result.implementation_head_sha,
        evidence_head_sha: result.evidence_head_sha,
        critic_report_head_sha: result.critic_report_head_sha,
        dispatch_head_sha: result.dispatch_head_sha
      )
    end

    def validate_critic_status(result:, pull_request_head_sha:)
      errors = result.errors.dup
      pull_head = pull_request_head_sha.to_s
      report_head = result.critic_report_head_sha.to_s
      errors << "live pull request head must be a full 40-character commit SHA" unless full_sha?(pull_head)
      errors << "live pull request head must equal the critic report head" unless pull_head == report_head
      unless result.critic && APPROVING_OUTCOMES.include?(result.critic["outcome"])
        errors << "critic outcome must approve integration"
      end

      Result.new(
        errors: errors.uniq,
        contract: result.contract,
        closeout: result.closeout,
        critic: result.critic,
        implementation_head_sha: result.implementation_head_sha,
        evidence_head_sha: result.evidence_head_sha,
        critic_report_head_sha: result.critic_report_head_sha,
        dispatch_head_sha: result.dispatch_head_sha
      )
    end

    private

    def absolute_path(path)
      candidate = Pathname.new(path)
      expanded = candidate.absolute? ? candidate.expand_path : @repo.root.join(candidate).expand_path
      expanded.exist? ? expanded.realpath : expanded
    end

    def relative_path(path, errors)
      return nil unless path

      relative = path.relative_path_from(@repo.root)
      if relative.to_s == ".." || relative.to_s.start_with?("../")
        errors << "artifact path escapes the repository: #{path}"
        nil
      else
        relative
      end
    rescue ArgumentError
      errors << "artifact path escapes the repository: #{path}"
      nil
    end

    def load_artifact(path, schema_name, errors)
      unless path&.file?
        errors << "artifact does not exist: #{path}"
        return nil
      end

      document = SchemaValidator.load_document(path)
      schema = SchemaValidator.load_document(Verdify::ROOT.join("schemas", schema_name))
      SchemaValidator.new.validate(document, schema).each { |error| errors << "#{path.basename}: #{error}" }
      SemanticValidator.validate(document).each { |error| errors << "#{path.basename}: #{error}" }
      document
    rescue Error => e
      errors << "#{path}: #{e.message}"
      nil
    end

    def compare_identity(contract, artifact, errors)
      errors << "artifact sprint_id must match lane contract" unless artifact["sprint_id"] == contract["sprint_id"]
      errors << "artifact lane_id must match lane contract" unless artifact["lane_id"] == contract["lane_id"]
    end

    def contract_criterion_ids(contract)
      Array(contract["acceptance_criteria"]).map { |criterion| criterion["id"].to_s }
    end

    # Closeout claims must be a truthful subset of the lane contract: every
    # claimed criterion ID must exist in the contract (omissions are allowed),
    # and evidence that is not recorded in the closeout's own validation
    # results may not name critic, CI, integration, deployment, or outcome
    # evidence, because none of that exists at worker closeout time.
    def validate_closeout_claims(contract, closeout, errors)
      contract_ids = contract_criterion_ids(contract)
      claims = Array(closeout["acceptance_evidence"])
      unknown = (claims.map { |claim| claim["criterion_id"].to_s } - contract_ids).uniq
      errors << "closeout claims criteria missing from the lane contract: #{unknown.join(', ')}" unless unknown.empty?

      recorded = Array(closeout["validation_results"]).map { |result| result["id"].to_s }
      claims.each do |claim|
        unrecorded = Array(claim["evidence_ids"]).map(&:to_s) - recorded
        future = unrecorded.grep(FUTURE_PHASE_EVIDENCE_PATTERN).uniq
        next if future.empty?

        errors << "closeout claims future-phase evidence for #{claim['criterion_id']}: #{future.join(', ')} " \
                  "(a worker closeout cannot claim critic, CI, integration, deployment, or outcome evidence)"
      end
    end

    # An approving critic report must assess exactly the lane contract's
    # criterion set (order-independent): unknown and missing criterion IDs are
    # distinct bounded failures. Non-approving reports may be partial or empty
    # but may not assess criteria the contract does not define.
    def validate_critic_assessment(contract, critic, errors)
      contract_ids = contract_criterion_ids(contract)
      assessed = Array(critic["acceptance_assessment"]).map { |assessment| assessment["criterion_id"].to_s }
      unknown = (assessed - contract_ids).uniq
      errors << "critic report assesses criteria missing from the lane contract: #{unknown.join(', ')}" unless unknown.empty?
      return unless APPROVING_OUTCOMES.include?(critic["outcome"])

      missing = (contract_ids - assessed).uniq
      errors << "approving critic report does not assess lane contract criteria: #{missing.join(', ')}" unless missing.empty?
    end

    def full_sha?(value)
      value.to_s.match?(/\A[0-9a-f]{40}\z/i)
    end

    def validate_commit(sha, label, errors)
      unless full_sha?(sha)
        errors << "#{label} head must be a full 40-character commit SHA"
        return
      end
      errors << "#{label} head does not exist in the repository" unless @repo.commit_exists?(sha)
    end

    def commits_available?(*shas)
      shas.all? { |sha| full_sha?(sha) && @repo.commit_exists?(sha) }
    end

    def validate_linear_suffix(from_sha, to_sha, allowed_path, label, errors)
      return unless commits_available?(from_sha, to_sha)

      if from_sha == to_sha
        errors << "#{label} head must follow its source head"
        return
      end
      unless @repo.ancestor?(from_sha, to_sha)
        errors << "#{label} head must descend from its source head"
        return
      end

      commits = @repo.commits_between(from_sha, to_sha)
      commits.each do |commit|
        parents = @repo.commit_parents(commit)
        errors << "#{label} suffix contains merge commit #{commit}" unless parents.length == 1
        paths = @repo.changed_paths(commit)
        unless !paths.empty? && paths.all? { |path| path == allowed_path }
          errors << "#{label} commit #{commit} changes unauthorized paths: #{paths.join(', ')}"
        end
      end
      last_change = @repo.last_change_sha(allowed_path, ref: to_sha)
      errors << "#{label} head must be the commit that last changed #{allowed_path}" unless last_change == to_sha
    rescue CommandError => e
      errors << "could not validate #{label} Git history: #{e.message}"
    end

    def validate_dispatch_snapshot(baseline, implementation_head, contract_rel, errors)
      return nil unless commits_available?(baseline, implementation_head)

      commits = @repo.commits_between(baseline, implementation_head)
      if commits.length < 2
        errors << "implementation head must follow a separate approved dispatch commit"
        return nil
      end
      dispatch_head = commits.first
      sprint_root = contract_rel.dirname.parent.parent
      dispatch_paths = [
        contract_rel.to_s,
        sprint_root.join("sprint-plan.yaml").to_s,
        sprint_root.join("release/wave-release-plan.yaml").to_s
      ]
      changed = @repo.changed_paths(dispatch_head)
      errors << "dispatch commit must include the canonical lane contract" unless changed.include?(contract_rel.to_s)
      unauthorized = changed - dispatch_paths
      errors << "dispatch commit changes unauthorized paths: #{unauthorized.join(', ')}" unless unauthorized.empty?
      errors << "dispatch commit must be linear" unless @repo.commit_parents(dispatch_head).length == 1
      later_dispatch_changes = commits.drop(1).flat_map { |commit| @repo.changed_paths(commit) & dispatch_paths }
      unless later_dispatch_changes.empty?
        errors << "approved dispatch artifacts changed after the dispatch commit: #{later_dispatch_changes.uniq.sort.join(', ')}"
      end
      dispatch_head
    rescue CommandError => e
      errors << "could not validate approved dispatch snapshot: #{e.message}"
      nil
    end

    def validate_file_snapshot(path, ref, relative, label, errors)
      return unless path&.file? && relative

      committed = @repo.file_at(ref, relative)
      errors << "working #{label} does not match #{ref}:#{relative}" unless path.binread == committed
    rescue CommandError => e
      errors << "could not read committed #{label}: #{e.message}"
    end
  end
end
