#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"
require "open3"
require "optparse"
require "pathname"
require_relative "../lib/verdify"

ROOT = Pathname.new(File.expand_path("..", __dir__))

options = { sidecar: nil, ledger: nil, facts: nil, repository: nil, finalize: false }
OptionParser.new do |o|
  o.banner = "Usage: ruby scripts/release-transaction.rb --sidecar FILE --ledger FILE [--repository OWNER/REPO | --facts FILE] [--finalize]"
  o.on("--sidecar FILE", "Release-candidate sidecar") { |v| options[:sidecar] = Pathname.new(v).expand_path }
  o.on("--ledger FILE", "Ledger output path") { |v| options[:ledger] = Pathname.new(v).expand_path }
  o.on("--facts FILE", "Isolated authority-facts fixture") { |v| options[:facts] = Pathname.new(v).expand_path }
  o.on("--repository OWNER/REPO", "GitHub repository for live reconciliation") { |v| options[:repository] = v }
  o.on("--finalize", "Emit the completed ledger after release assets are verified") { options[:finalize] = true }
  o.on("-h", "--help") { puts o; exit 0 }
end.parse!

abort "--sidecar is required" unless options[:sidecar]
abort "--ledger is required" unless options[:ledger]
abort "choose exactly one of --facts or --repository" unless !!options[:facts] ^ !!options[:repository]

begin

def capture(*command, chdir: nil)
  Open3.capture3(*command, chdir: chdir)
end

def absent_npm
  { "status" => "absent", "version" => nil, "integrity" => nil, "git_head" => nil }
end

def absent_tag(name)
  { "status" => "absent", "name" => name, "commit" => nil }
end

def absent_release
  { "status" => "absent", "tag" => nil, "url" => nil, "required_assets_complete" => false, "completed_ledger_asset" => false }
end

sidecar_path = options.fetch(:sidecar)
abort "sidecar not found: #{sidecar_path}" unless sidecar_path.file?
sidecar = JSON.parse(sidecar_path.read)
package_name = sidecar.dig("package", "name").to_s
version = sidecar.dig("package", "version").to_s
source_sha = sidecar.dig("source", "commit").to_s
tag_name = "v#{version}"
artifact_dir = sidecar_path.dirname
tarball_path = artifact_dir.join(sidecar.dig("tarball", "filename").to_s)
archive_path = artifact_dir.join(sidecar.dig("archive", "filename").to_s)
checksum_path = artifact_dir.join(sidecar.dig("archive", "checksum_filename").to_s)
completed_ledger_name = "release-transaction-v#{version}.json"
errors = []
completed_ledger_remote_digest = nil

artifact_verified = false
if options[:facts]
  facts = JSON.parse(options.fetch(:facts).read)
  artifact_verified = facts.fetch("artifact_verified", true)
  npm = facts.fetch("npm", absent_npm)
  tag = facts.fetch("tag", absent_tag(tag_name))
  release = facts.fetch("github_release", absent_release)
else
  unless sidecar.dig("source", "clean") == true
    errors << "candidate sidecar does not identify a clean source"
  end
  head, head_error, head_status = capture("git", "rev-parse", "HEAD", chdir: ROOT.to_s)
  errors << "cannot read source HEAD: #{head_error.strip}" unless head_status.success?
  errors << "candidate source commit does not match clean HEAD" if head_status.success? && head.strip != source_sha
  status, status_error, status_result = capture("git", "status", "--porcelain", "--untracked-files=all", chdir: ROOT.to_s)
  errors << "cannot inspect source worktree: #{status_error.strip}" unless status_result.success?
  errors << "candidate source worktree is not clean" if status_result.success? && !status.empty?

  tarball_ok = system("ruby", ROOT.join("scripts/verify-npm-tarball.rb").to_s, "--tarball", tarball_path.to_s, "--sidecar", sidecar_path.to_s, out: File::NULL)
  archive_ok = system("bash", ROOT.join("scripts/verify-package.sh").to_s, archive_path.to_s, out: File::NULL)
  errors << "exact npm tarball verification failed" unless tarball_ok
  errors << "exact release archive verification failed" unless archive_ok
  if checksum_path.file?
    expected_checksum = checksum_path.read.split.first
    errors << "archive checksum sidecar does not match archive" unless expected_checksum == Digest::SHA256.file(archive_path).hexdigest
  else
    errors << "archive checksum sidecar is missing"
  end
  artifact_verified = errors.empty?

  target = "#{package_name}@#{version}"
  npm_stdout, npm_stderr, npm_result = capture("npm", "view", target, "version", "dist.integrity", "gitHead", "--json", chdir: ROOT.to_s)
  if npm_result.success?
    detail = JSON.parse(npm_stdout)
    npm = {
      "status" => "published",
      "version" => detail["version"],
      "integrity" => detail["dist.integrity"],
      "git_head" => detail["gitHead"]
    }
  elsif [npm_stdout, npm_stderr].join("\n").match?(/(?:E404|404 Not Found|is not in this registry)/i)
    npm = absent_npm
  else
    npm = { "status" => "unknown", "version" => nil, "integrity" => nil, "git_head" => nil }
    errors << "npm authority query failed"
  end

  tag_stdout, tag_stderr, tag_result = capture("git", "ls-remote", "--tags", "origin", "refs/tags/#{tag_name}", "refs/tags/#{tag_name}^{}", chdir: ROOT.to_s)
  if !tag_result.success?
    tag = { "status" => "unknown", "name" => tag_name, "commit" => nil }
    errors << "tag authority query failed: #{tag_stderr.strip}"
  elsif tag_stdout.empty?
    tag = absent_tag(tag_name)
  else
    refs = tag_stdout.lines(chomp: true).map { |line| line.split(/\s+/, 2) }.to_h { |sha, ref| [ref, sha] }
    commit = refs["refs/tags/#{tag_name}^{}"] || refs["refs/tags/#{tag_name}"]
    tag = { "status" => "present", "name" => tag_name, "commit" => commit }
  end

  release_stdout, release_stderr, release_result = capture("gh", "api", "repos/#{options.fetch(:repository)}/releases/tags/#{tag_name}", chdir: ROOT.to_s)
  if release_result.success?
    detail = JSON.parse(release_stdout)
    assets = Array(detail["assets"]).to_h { |asset| [asset.fetch("name"), asset] }
    expected_assets = {
      tarball_path.basename.to_s => Digest::SHA256.file(tarball_path).hexdigest,
      sidecar_path.basename.to_s => Digest::SHA256.file(sidecar_path).hexdigest,
      archive_path.basename.to_s => Digest::SHA256.file(archive_path).hexdigest,
      checksum_path.basename.to_s => Digest::SHA256.file(checksum_path).hexdigest
    }
    missing_assets = expected_assets.keys - assets.keys
    mismatched_assets = expected_assets.filter_map do |name, digest|
      asset = assets[name]
      next unless asset
      name unless asset["digest"] == "sha256:#{digest}"
    end
    errors << "GitHub release assets have mismatched digests: #{mismatched_assets.sort.join(', ')}" unless mismatched_assets.empty?
    complete = missing_assets.empty? && mismatched_assets.empty?
    release = {
      "status" => complete ? "present" : "partial",
      "tag" => detail["tag_name"],
      "url" => detail["html_url"],
      "required_assets_complete" => complete,
      "completed_ledger_asset" => assets.key?(completed_ledger_name)
    }
    if assets[completed_ledger_name]
      completed_ledger_remote_digest = assets.fetch(completed_ledger_name)["digest"]
      errors << "completed release ledger digest is unavailable" unless completed_ledger_remote_digest&.match?(/\Asha256:[0-9a-f]{64}\z/)
    end
    errors << "GitHub release is draft or prerelease" if detail["draft"] || detail["prerelease"]
  elsif [release_stdout, release_stderr].join("\n").match?(/(?:HTTP 404|Not Found|release not found)/i)
    release = absent_release
  else
    release = { "status" => "unknown", "tag" => nil, "url" => nil, "required_assets_complete" => false, "completed_ledger_asset" => false }
    errors << "GitHub release authority query failed"
  end
end

errors << "npm package version does not match candidate" if npm["status"] == "published" && npm["version"] != version
errors << "npm integrity does not match candidate tarball" if npm["status"] == "published" && npm["integrity"] != sidecar.dig("tarball", "integrity")
errors << "npm gitHead does not match candidate source" if npm["status"] == "published" && npm["git_head"] != source_sha
errors << "tag commit does not match candidate source" if tag["status"] == "present" && tag["commit"] != source_sha
errors << "GitHub release tag does not match candidate" if %w[partial present].include?(release["status"]) && release["tag"] != tag_name
errors << "tag exists before npm publication" if tag["status"] == "present" && npm["status"] != "published"
errors << "GitHub release exists before matching tag" if %w[partial present].include?(release["status"]) && tag["status"] != "present"
errors << "one or more release authorities are unknown" if [npm["status"], tag["status"], release["status"]].include?("unknown")

unknown_authority = [npm["status"], tag["status"], release["status"]].include?("unknown")
state, next_action, resumable = if errors.any?
                                  ["failed", "manual_reconcile", unknown_authority]
                                elsif !artifact_verified
                                  ["prepared", "verify_artifact", true]
                                elsif npm["status"] == "absent"
                                  ["artifact_verified", "publish_npm", true]
                                elsif tag["status"] == "absent"
                                  ["npm_published", "push_tag", true]
                                elsif release["status"] == "absent"
                                  ["tag_pushed", "create_github_release", true]
                                elsif release["status"] == "partial"
                                  ["github_released", "upload_release_assets", true]
                                elsif !release["completed_ledger_asset"]
                                  ["github_released", "upload_completed_ledger", true]
                                else
                                  ["completed", "none", false]
                                end

if options[:finalize]
  unless state == "github_released" && next_action == "upload_completed_ledger"
    errors << "completed ledger can only be finalized after all immutable release assets are verified"
    state = "failed"
    next_action = "manual_reconcile"
    resumable = false
  else
    release["completed_ledger_asset"] = true
    state = "completed"
    next_action = "none"
    resumable = false
  end
end

ledger = {
  "schema_ref" => "release-transaction.schema.yaml",
  "kind" => "ReleaseTransaction",
  "schema_version" => "1.0",
  "state" => state,
  "resumable" => resumable,
  "next_action" => next_action,
  "package" => { "name" => package_name, "version" => version },
  "source" => {
    "commit" => source_sha,
    "clean" => sidecar.dig("source", "clean") == true,
    "candidate_sidecar_sha256" => Digest::SHA256.file(sidecar_path).hexdigest
  },
  "artifact" => {
    "tarball_filename" => sidecar.dig("tarball", "filename"),
    "tarball_sha256" => sidecar.dig("tarball", "sha256"),
    "tarball_sha512" => sidecar.dig("tarball", "sha512"),
    "npm_integrity" => sidecar.dig("tarball", "integrity"),
    "npm_shasum" => sidecar.dig("tarball", "npm_shasum"),
    "npm_pack_invocations" => sidecar.dig("build", "npm_pack_invocations"),
    "archive_filename" => sidecar.dig("archive", "filename"),
    "archive_sha256" => sidecar.dig("archive", "sha256"),
    "checksum_filename" => sidecar.dig("archive", "checksum_filename")
  },
  "authorities" => { "npm" => npm, "tag" => tag, "github_release" => release },
  "errors" => errors.uniq.sort
}

if completed_ledger_remote_digest && state == "completed"
  expected_digest = "sha256:#{Digest::SHA256.hexdigest(JSON.pretty_generate(ledger) + "\n")}"
  if completed_ledger_remote_digest != expected_digest
    ledger["state"] = "failed"
    ledger["resumable"] = false
    ledger["next_action"] = "manual_reconcile"
    ledger["errors"] = (ledger.fetch("errors") + ["completed release ledger digest does not match reconstructed authority facts"]).uniq.sort
    state = "failed"
    next_action = "manual_reconcile"
    resumable = false
  end
end

schema = Verdify::SchemaValidator.load_document(ROOT.join("schemas/release-transaction.schema.yaml"))
validation_errors = Verdify::SchemaValidator.new.validate(ledger, schema)
abort "release ledger failed schema validation:\n#{validation_errors.join("\n")}" unless validation_errors.empty?
Verdify.atomic_write(options.fetch(:ledger), JSON.pretty_generate(ledger) + "\n")
puts JSON.generate({ "state" => state, "next_action" => next_action, "ledger" => options.fetch(:ledger).to_s })
exit(state == "failed" ? 1 : 0)
rescue JSON::ParserError, KeyError => e
  abort "release transaction input is invalid: #{e.message}"
end
