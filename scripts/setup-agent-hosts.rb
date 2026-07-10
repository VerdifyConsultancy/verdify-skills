#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "optparse"
require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("..", __dir__))
SKILLS = Dir[ROOT.join("skills/*/SKILL.md")].sort.map { |p| Pathname.new(p).dirname.basename.to_s }

options = { root: ROOT, source: ROOT, check: false, hosts: %w[codex claude], pack: "all", include_optional: false }
OptionParser.new do |o|
  o.banner = "Usage: ruby scripts/setup-agent-hosts.rb [--check] [--root PATH] [--source PATH] [--host codex|claude|all] [--pack NAME|all] [--include-optional]"
  o.on("--check", "Check links without modifying them") { options[:check] = true }
  o.on("--root PATH", "Repository where host links are installed") { |v| options[:root] = Pathname.new(v).expand_path }
  o.on("--source PATH", "Verdify package containing skills/") { |v| options[:source] = Pathname.new(v).expand_path }
  o.on("--host HOST", %w[codex claude all]) { |v| options[:hosts] = v == "all" ? %w[codex claude] : [v] }
  o.on("--pack NAME", "Skill pack to link; use all for every skill") { |v| options[:pack] = v }
  o.on("--include-optional", "Include optional skills declared by the pack") { options[:include_optional] = true }
  o.on("-h", "--help") { puts o; exit 0 }
end.parse!

HOST_DIRS = { "codex" => ".agents/skills", "claude" => ".claude/skills" }.freeze
errors = []

def pack_skills(source, name, include_optional)
  all_skills = Dir[source.join("skills/*/SKILL.md")].sort.map { |p| Pathname.new(p).dirname.basename.to_s }
  return all_skills if name == "all"

  unless name.to_s.match?(/\A[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\z/)
    raise "invalid skill pack #{name.inspect}"
  end

  path = source.join("packs", name, "pack.yaml")
  raise "unknown skill pack #{name.inspect}; expected #{path}" unless path.file?

  pack = YAML.safe_load(path.read, permitted_classes: [], aliases: false) || {}
  raise "skill pack #{name.inspect} must be a mapping" unless pack.is_a?(Hash)
  raise "skill pack name does not match directory: #{name}" unless pack["name"] == name

  skills = Array(pack.dig("includes", "required")).map(&:to_s)
  skills += Array(pack.dig("includes", "optional")).map(&:to_s) if include_optional
  skills = skills.uniq
  missing = skills - all_skills
  raise "skill pack #{name} references unknown skills: #{missing.join(', ')}" unless missing.empty?

  skills
end

begin
  selected_skills = pack_skills(options[:source], options[:pack], options[:include_optional])
rescue StandardError => e
  warn e.message
  exit 2
end

options[:hosts].each do |host|
  host_dir = options[:root].join(HOST_DIRS.fetch(host))
  FileUtils.mkdir_p(host_dir) unless options[:check]
  selected_skills.each do |skill|
    source = options[:source].join("skills", skill)
    link = host_dir.join(skill)
    unless source.join("SKILL.md").file?
      errors << "missing source skill #{source}"
      next
    end
    if options[:check]
      unless link.symlink?
        errors << "#{link} is not a symlink"
        next
      end
      begin
        errors << "#{link} resolves to #{link.realpath}, expected #{source.realpath}" unless link.realpath == source.realpath
      rescue Errno::ENOENT
        errors << "#{link} is broken"
      end
      next
    end

    if link.exist? || link.symlink?
      begin
        next if link.symlink? && link.realpath == source.realpath
      rescue Errno::ENOENT
        # replace broken link below
      end
      FileUtils.rm_rf(link)
    end
    relative = source.relative_path_from(link.dirname)
    File.symlink(relative, link)
    puts "linked #{link} -> #{relative}"
  end
end

unless errors.empty?
  warn errors.join("\n")
  exit 1
end
label = options[:pack] == "all" ? "all skills" : "pack #{options[:pack]}"
puts(options[:check] ? "Agent host links are valid for #{label}." : "Agent host links installed for #{label}.")
