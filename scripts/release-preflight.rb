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
  skip_registry: false
}

OptionParser.new do |o|
  o.banner = "Usage: ruby scripts/release-preflight.rb [--root PATH] [--require-version-bump GIT-REF] [--require-unpublished] [--skip-registry]"
  o.on("--root PATH", "Repository root to inspect") { |v| options[:root] = Pathname.new(v).expand_path }
  o.on("--require-version-bump GIT-REF", "Require package.json and VERSION to differ from GIT-REF") { |v| options[:require_version_bump] = v }
  o.on("--require-unpublished", "Fail when the current npm package version is already published") { options[:require_unpublished] = true }
  o.on("--skip-registry", "Skip npm registry checks") { options[:skip_registry] = true }
  o.on("-h", "--help") { puts o; exit 0 }
end.parse!

root = options.fetch(:root)
errors = []

def read_package(root)
  JSON.parse(root.join("package.json").read)
rescue JSON::ParserError => e
  abort "package.json is not valid JSON: #{e.message}"
end

def read_version(root)
  root.join("VERSION").read.strip
end

def git_show(root, ref, path)
  stdout, stderr, status = Open3.capture3("git", "-C", root.to_s, "show", "#{ref}:#{path}")
  abort "cannot read #{path} from #{ref}: #{stderr.strip}" unless status.success?
  stdout
end

package = read_package(root)
package_name = package.fetch("name").to_s
package_version = package.fetch("version").to_s
file_version = read_version(root)
npm_status = nil
npm_detail = nil

errors << "package.json name is missing" if package_name.empty?
errors << "package.json version is missing" if package_version.empty?
errors << "VERSION is missing" if file_version.empty?
errors << "package.json version #{package_version.inspect} does not match VERSION #{file_version.inspect}" unless package_version == file_version
errors << "version #{package_version.inspect} is not a SemVer release version" unless package_version.match?(/\A\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?\z/)

if (options[:require_unpublished] || options[:require_version_bump]) && !options[:skip_registry] && errors.empty?
  target = "#{package_name}@#{package_version}"
  stdout, stderr, status = Open3.capture3("npm", "view", target, "version", "--json", chdir: root.to_s)
  registry_output = [stdout, stderr].join("\n")

  if status.success?
    npm_status = :published
    npm_detail = stdout.strip.delete_prefix('"').delete_suffix('"')
  elsif registry_output.match?(/(?:E404|404 Not Found|is not in this registry)/i)
    npm_status = :unpublished
  else
    npm_status = :unknown
    npm_detail = registry_output.strip
  end
end

if options[:require_version_bump]
  base_ref = options.fetch(:require_version_bump)
  base_package = JSON.parse(git_show(root, base_ref, "package.json"))
  base_package_version = base_package.fetch("version").to_s
  base_file_version = git_show(root, base_ref, "VERSION").strip

  errors << "base package.json version #{base_package_version.inspect} does not match base VERSION #{base_file_version.inspect}" unless base_package_version == base_file_version
  if base_package_version == package_version && npm_status != :unpublished
    errors << "package.json version must be bumped from #{base_package_version}"
  end
  if base_file_version == file_version && npm_status != :unpublished
    errors << "VERSION must be bumped from #{base_file_version}"
  end
end

if options[:require_unpublished] && !options[:skip_registry] && errors.empty?
  target = "#{package_name}@#{package_version}"
  case npm_status
  when :published
    errors << "#{target} is already published#{npm_detail.to_s.empty? ? '' : " as #{npm_detail}"}"
  when :unpublished
    # Expected when the release version has not been published yet.
  else
    errors << "could not determine whether #{target} is published: #{npm_detail}"
  end
end

if errors.empty?
  puts "Release preflight passed for #{package_name}@#{package_version}"
  exit 0
end

warn "Release preflight failed:"
errors.each { |error| warn "  - #{error}" }
exit 1
