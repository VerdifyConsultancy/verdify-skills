#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "open3"
require "optparse"
require "pathname"

ROOT = Pathname.new(File.expand_path("..", __dir__))

options = {
  root: ROOT,
  require_version_bump: nil,
  require_unpublished: false,
  release_pr_base: nil,
  skip_registry: false,
  json: false
}

OptionParser.new do |o|
  o.banner = "Usage: ruby scripts/release-preflight.rb [--root PATH] [--require-version-bump GIT-REF] [--require-unpublished] [--release-pr-base GIT-REF] [--skip-registry] [--json]"
  o.on("--root PATH", "Repository root to inspect") { |v| options[:root] = Pathname.new(v).expand_path }
  o.on("--require-version-bump GIT-REF", "Require package.json and VERSION to differ from GIT-REF") { |v| options[:require_version_bump] = v }
  o.on("--require-unpublished", "Fail when the current npm package version is already published") { options[:require_unpublished] = true }
  o.on("--release-pr-base GIT-REF", "Return create/skip for release-PR automation") { |v| options[:release_pr_base] = v }
  o.on("--skip-registry", "Skip npm registry checks") { options[:skip_registry] = true }
  o.on("--json", "Emit a machine-readable result") { options[:json] = true }
  o.on("-h", "--help") { puts o; exit 0 }
end.parse!

root = options.fetch(:root)
errors = []

def read_package(root)
  JSON.parse(root.join("package.json").read)
rescue JSON::ParserError => e
  abort "package.json is not valid JSON: #{e.message}"
end

def git_show(root, ref, path)
  stdout, stderr, status = Open3.capture3("git", "-C", root.to_s, "show", "#{ref}:#{path}")
  abort "cannot read #{path} from #{ref}: #{stderr.strip}" unless status.success?
  stdout
end

def npm_status(root, target)
  stdout, stderr, status = Open3.capture3("npm", "view", target, "version", "dist.integrity", "gitHead", "--json", chdir: root.to_s)
  combined = [stdout, stderr].join("\n")
  if status.success?
    [:published, JSON.parse(stdout)]
  elsif combined.match?(/(?:E404|404 Not Found|is not in this registry)/i)
    [:unpublished, nil]
  else
    [:unknown, combined.strip]
  end
rescue JSON::ParserError => e
  [:unknown, "invalid npm registry JSON: #{e.message}"]
end

package = read_package(root)
package_name = package.fetch("name", "").to_s
package_version = package.fetch("version", "").to_s
file_version = root.join("VERSION").read.strip
target = "#{package_name}@#{package_version}"

errors << "package.json name is missing" if package_name.empty?
errors << "package.json version is missing" if package_version.empty?
errors << "VERSION is missing" if file_version.empty?
errors << "package.json version #{package_version.inspect} does not match VERSION #{file_version.inspect}" unless package_version == file_version
errors << "version #{package_version.inspect} is not a SemVer release version" unless package_version.match?(/\A\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?\z/)

base_ref = options[:release_pr_base] || options[:require_version_bump]
base_version = nil
if base_ref
  base_package = JSON.parse(git_show(root, base_ref, "package.json"))
  base_version = base_package.fetch("version").to_s
  base_file_version = git_show(root, base_ref, "VERSION").strip
  errors << "base package.json version #{base_version.inspect} does not match base VERSION #{base_file_version.inspect}" unless base_version == base_file_version
end

registry_status = nil
registry_detail = nil
registry_required = options[:require_unpublished] || options[:release_pr_base] || options[:require_version_bump]
if registry_required && !options[:skip_registry] && errors.empty?
  registry_status, registry_detail = npm_status(root, target)
  errors << "could not determine whether #{target} is published: #{registry_detail}" if registry_status == :unknown
end

if options[:release_pr_base]
  errors << "release PR preflight cannot skip the npm registry query" if options[:skip_registry]
  result = if errors.any?
             { "decision" => "error", "reason" => "preflight_failed" }
           elsif registry_status == :published
             { "decision" => "skip", "reason" => "already_published" }
           elsif package_version == base_version
             { "decision" => "skip", "reason" => "version_not_bumped" }
           elsif registry_status == :unpublished
             { "decision" => "create", "reason" => "new_unpublished_version" }
           else
             { "decision" => "error", "reason" => "registry_state_unknown" }
           end
  result.merge!("package" => target, "version" => package_version, "base_version" => base_version, "npm_status" => registry_status&.to_s)
  if options[:json]
    puts JSON.generate(result)
  else
    puts "Release PR preflight: #{result.fetch('decision')} (#{result.fetch('reason')}) for #{target}"
  end
  if errors.any?
    errors.each { |error| warn "  - #{error}" }
    exit 1
  end
  exit(result.fetch("decision") == "error" ? 1 : 0)
end

if options[:require_version_bump] && package_version == base_version
  errors << "package.json version must be bumped from #{base_version}"
  errors << "VERSION must be bumped from #{base_version}"
end
if options[:require_unpublished] && !options[:skip_registry] && registry_status == :published
  errors << "#{target} is already published"
end

result = {
  "decision" => errors.empty? ? "pass" : "error",
  "package" => target,
  "version" => package_version,
  "base_version" => base_version,
  "npm_status" => registry_status&.to_s,
  "errors" => errors
}
if options[:json]
  puts JSON.generate(result)
elsif errors.empty?
  puts "Release preflight passed for #{target}"
else
  warn "Release preflight failed:"
  errors.each { |error| warn "  - #{error}" }
end
exit(errors.empty? ? 0 : 1)
