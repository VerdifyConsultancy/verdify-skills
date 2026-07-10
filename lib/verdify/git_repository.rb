# frozen_string_literal: true

module Verdify
  class GitRepository
    attr_reader :root

    def initialize(path)
      requested = Pathname.new(path).expand_path
      stdout, = capture("git", "-C", requested.to_s, "rev-parse", "--show-toplevel")
      @root = Pathname.new(stdout.strip).expand_path
    rescue CommandError
      raise UsageError, "Not a Git repository: #{requested}"
    end

    def capture(*command, allow_failure: false)
      stdout, stderr, status = Open3.capture3(*command)
      unless status.success? || allow_failure
        raise CommandError, "Command failed (#{command.shelljoin}): #{stderr.strip.empty? ? stdout.strip : stderr.strip}"
      end
      [stdout, stderr, status]
    rescue Errno::ENOENT => e
      raise CommandError, "Command not available: #{e.message}"
    end

    def output(*command)
      capture(*command).first.strip
    end

    def git(*args, allow_failure: false)
      capture("git", "-C", root.to_s, *args, allow_failure: allow_failure)
    end

    def head_sha(ref = "HEAD")
      git("rev-parse", "#{ref}^{commit}").first.strip
    end

    def commit_exists?(ref)
      git("cat-file", "-e", "#{ref}^{commit}", allow_failure: true).last.success?
    end

    def ancestor?(ancestor, descendant)
      git("merge-base", "--is-ancestor", ancestor.to_s, descendant.to_s, allow_failure: true).last.success?
    end

    def commit_parents(ref)
      fields = git("rev-list", "--parents", "-n", "1", ref.to_s).first.strip.split
      fields.drop(1)
    end

    def commits_between(ancestor, descendant)
      return [] if ancestor.to_s == descendant.to_s

      git("rev-list", "--reverse", "#{ancestor}..#{descendant}").first.lines.map(&:strip).reject(&:empty?)
    end

    def changed_paths(commit)
      git("diff-tree", "--root", "--no-commit-id", "--name-only", "-r", commit.to_s).first.lines.map(&:strip).reject(&:empty?).uniq.sort
    end

    def tracked_paths(ref: "HEAD", pathspec: nil)
      args = ["ls-tree", "-r", "--name-only", ref.to_s]
      args.concat(["--", pathspec.to_s]) unless pathspec.to_s.empty?
      git(*args).first.lines.map(&:strip).reject(&:empty?).uniq.sort
    end

    def last_change_sha(path, ref: "HEAD")
      value = git("log", "-1", "--format=%H", ref.to_s, "--", path.to_s).first.strip
      value.empty? ? nil : value
    end

    def first_change_sha(path, ref: "HEAD")
      git("rev-list", "--reverse", ref.to_s, "--", path.to_s).first.lines.map(&:strip).find { |sha| !sha.empty? }
    end

    def file_at(ref, path)
      git("show", "#{ref}:#{path}").first.b
    end

    def fetch_pull_request_head(number)
      git("fetch", "--quiet", "origin", "pull/#{Integer(number)}/head")
      head_sha("FETCH_HEAD")
    end

    def fetch_branch_head(branch)
      git("fetch", "--quiet", "origin", "refs/heads/#{branch}")
      head_sha("FETCH_HEAD")
    end

    def github_pull_request_evidence(number)
      slug = github_slug
      raise CommandError, "GitHub remote is not configured" if slug.to_s.empty?

      pr = JSON.parse(output("gh", "api", "repos/#{slug}/pulls/#{Integer(number)}"))
      rollup = JSON.parse(output("gh", "pr", "view", Integer(number).to_s, "--repo", slug, "--json", "author,baseRefName,headRefName,headRefOid,isDraft,mergeStateStatus,reviews,state,statusCheckRollup"))
      final_pr = JSON.parse(output("gh", "api", "repos/#{slug}/pulls/#{Integer(number)}"))
      observed_heads = [pr.dig("head", "sha"), rollup["headRefOid"], final_pr.dig("head", "sha")]
      unless observed_heads.all? { |sha| sha.to_s.match?(/\A[0-9a-f]{40}\z/i) } && observed_heads.uniq.length == 1
        raise CommandError, "Pull request head changed or was missing while evidence was being collected"
      end
      pr = final_pr
      {
        "number" => Integer(number),
        "head_sha" => pr.dig("head", "sha"),
        "head_ref" => rollup["headRefName"],
        "base_ref" => rollup["baseRefName"],
        "state" => rollup["state"],
        "draft" => rollup["isDraft"],
        "merged" => pr["merged"] == true || rollup["state"].to_s.upcase == "MERGED",
        "merge_commit_sha" => pr["merge_commit_sha"],
        "merge_state_status" => rollup["mergeStateStatus"],
        "checks" => Array(rollup["statusCheckRollup"]).map do |check|
          {
            "id" => check["databaseId"] || check["id"] || check["detailsUrl"] || check["targetUrl"],
            "name" => check["name"] || check["context"],
            "status" => check["status"],
            "conclusion" => check["conclusion"] || check["state"],
            "workflow" => check["workflowName"],
            "started_at" => check["startedAt"] || check["createdAt"],
            "completed_at" => check["completedAt"] || check["updatedAt"]
          }
        end,
        "author" => rollup.dig("author", "login"),
        "author_id" => pr.dig("user", "id"),
        "reviews" => Array(rollup["reviews"]).map do |review|
          {
            "id" => review["id"],
            "state" => review["state"],
            "commit_id" => review.dig("commit", "oid"),
            "reviewer" => review.dig("author", "login"),
            "submitted_at" => review["submittedAt"]
          }
        end
      }
    rescue JSON::ParserError, ArgumentError => e
      raise CommandError, "Could not read GitHub pull request evidence: #{e.message}"
    end

    def github_terminal_pull_request_evidence(number)
      slug = github_slug
      raise CommandError, "GitHub remote is not configured" if slug.to_s.empty?

      first = github_api_json("repos/#{slug}/pulls/#{Integer(number)}")
      final = github_api_json("repos/#{slug}/pulls/#{Integer(number)}")
      observed_heads = [first.dig("head", "sha"), final.dig("head", "sha")]
      unless observed_heads.all? { |sha| sha.to_s.match?(/\A[0-9a-f]{40}\z/i) } && observed_heads.uniq.length == 1
        raise CommandError, "Pull request head changed or was missing while terminal evidence was collected"
      end
      {
        "number" => Integer(number),
        "head_sha" => final.dig("head", "sha"),
        "head_ref" => final.dig("head", "ref"),
        "base_ref" => final.dig("base", "ref"),
        "state" => final["state"],
        "draft" => final["draft"],
        "merged" => final["merged"] == true,
        "merge_commit_sha" => final["merge_commit_sha"],
        "author" => final.dig("user", "login"),
        "author_id" => final.dig("user", "id")
      }
    rescue JSON::ParserError, ArgumentError => e
      raise CommandError, "Could not read GitHub terminal pull request evidence: #{e.message}"
    end

    def github_check_run_evidence(ref)
      slug = github_slug
      raise CommandError, "GitHub remote is not configured" if slug.to_s.empty?

      payload = github_api_json("repos/#{slug}/commits/#{ref}/check-runs?filter=latest&per_page=100")
      workflow_runs = {}
      Array(payload["check_runs"]).map do |check|
        run_id = check["details_url"].to_s[%r{/actions/runs/(\d+)}, 1]
        run = if run_id
                workflow_runs[run_id] ||= github_api_json("repos/#{slug}/actions/runs/#{run_id}")
              else
                {}
              end
        workflow_path = run["path"].to_s.split("@", 2).first
        {
          "id" => check["id"],
          "name" => check["name"],
          "status" => check["status"],
          "conclusion" => check["conclusion"],
          "created_at" => check["created_at"],
          "started_at" => check["started_at"],
          "completed_at" => check["completed_at"],
          "app_slug" => check.dig("app", "slug"),
          "details_url" => check["details_url"],
          "run_id" => run_id&.to_i,
          "workflow_path" => workflow_path,
          "workflow_event" => run["event"],
          "workflow_head_sha" => run["head_sha"]
        }
      end
    rescue JSON::ParserError => e
      raise CommandError, "Could not read GitHub check-run evidence: #{e.message}"
    end

    def github_collaborator_permission(login)
      slug = github_slug
      raise CommandError, "GitHub remote is not configured" if slug.to_s.empty?

      payload = JSON.parse(output("gh", "api", "repos/#{slug}/collaborators/#{login}/permission"))
      {
        "permission" => payload["permission"],
        "login" => payload.dig("user", "login"),
        "id" => payload.dig("user", "id")
      }
    rescue JSON::ParserError => e
      raise CommandError, "Could not read GitHub collaborator permission for #{login}: #{e.message}"
    end

    def github_pull_request_for_branch(branch)
      slug = github_slug
      raise CommandError, "GitHub remote is not configured" if slug.to_s.empty?

      pr = JSON.parse(output("gh", "pr", "view", branch.to_s, "--repo", slug, "--json", "number,headRefOid"))
      { "number" => pr["number"], "head_sha" => pr["headRefOid"] }
    rescue JSON::ParserError => e
      raise CommandError, "Could not find GitHub pull request for branch #{branch}: #{e.message}"
    end

    def remote_branch_sha(branch, remote: "origin")
      output = git("ls-remote", "--heads", remote, "refs/heads/#{branch}").first.strip
      sha = output.split.first
      sha if sha&.match?(/\A[0-9a-f]{40}\z/i)
    end

    def current_branch
      git("branch", "--show-current").first.strip
    end

    def default_branch
      remote_head = git("symbolic-ref", "--quiet", "--short", "refs/remotes/origin/HEAD", allow_failure: true)
      if remote_head.last.success?
        return remote_head.first.strip.sub(%r{\Aorigin/}, "")
      end
      %w[main master].find { |name| branch_exists?(name) } || current_branch
    end

    def clean?(path = root)
      stdout, = capture("git", "-C", path.to_s, "status", "--porcelain")
      stdout.strip.empty?
    end

    def branch_exists?(branch)
      git("show-ref", "--verify", "--quiet", "refs/heads/#{branch}", allow_failure: true).last.success?
    end

    def common_dir
      raw = git("rev-parse", "--git-common-dir").first.strip
      path = Pathname.new(raw)
      path.absolute? ? path : root.join(path).cleanpath
    end

    def remote_url
      result = git("remote", "get-url", "origin", allow_failure: true)
      result.last.success? ? result.first.strip : nil
    end

    def github_api_json(path)
      gh = capture("gh", "api", path.to_s, allow_failure: true)
      return JSON.parse(gh.first) if gh.last.success?
      github_api_json_with_curl(path)
    rescue CommandError, JSON::ParserError
      github_api_json_with_curl(path)
    end

    def github_api_json_with_curl(path)
      url = "https://api.github.com/#{path}"
      stdout, stderr, status = capture(
        "curl", "-fsSL",
        "-H", "Accept: application/vnd.github+json",
        "-H", "X-GitHub-Api-Version: 2022-11-28",
        url,
        allow_failure: true
      )
      raise CommandError, "GitHub API request failed for #{path}: #{stderr.strip}" unless status.success?

      JSON.parse(stdout)
    rescue JSON::ParserError => e
      raise CommandError, "GitHub API returned invalid JSON for #{path}: #{e.message}"
    end

    def github_slug
      url = remote_url
      return nil if url.nil? || url.empty?
      match = url.match(%r{github\.com[:/](?<slug>[^/]+/[^/]+?)(?:\.git)?\z})
      match && match[:slug]
    end

    def add_worktree(path:, branch:, base:, detach: false)
      FileUtils.mkdir_p(Pathname.new(path).dirname)
      if detach
        git("worktree", "add", "--detach", path.to_s, base)
      elsif branch_exists?(branch)
        git("worktree", "add", path.to_s, branch)
      else
        git("worktree", "add", "-b", branch, path.to_s, base)
      end
    end

    def lock_worktree(path, reason)
      result = git("worktree", "lock", "--reason", reason, path.to_s, allow_failure: true)
      return if result.last.success?

      fallback = git("worktree", "lock", path.to_s, allow_failure: true)
      raise CommandError, "Could not lock worktree #{path}: #{fallback[1].strip}" unless fallback.last.success?
    end

    def unlock_worktree(path)
      git("worktree", "unlock", path.to_s, allow_failure: true)
    end

    def remove_worktree(path, force: false)
      args = ["worktree", "remove"]
      args << "--force" if force
      args << path.to_s
      git(*args)
    end

    def worktrees
      stdout = git("worktree", "list", "--porcelain").first
      records = []
      current = {}
      stdout.each_line do |line|
        line = line.chomp
        if line.empty?
          records << current unless current.empty?
          current = {}
          next
        end
        key, value = line.split(" ", 2)
        current[key] = value || true
      end
      records << current unless current.empty?
      records
    end
  end
end
