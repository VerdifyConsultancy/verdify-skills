#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "pathname"

ROOT = Pathname.new(File.expand_path("..", __dir__))
CANONICAL_SKILL = ROOT.join("skills/verdify-agentic-sprint")

LINKS = {
  "Codex" => ROOT.join(".agents/skills/verdify-agentic-sprint"),
  "Claude Code" => ROOT.join(".claude/skills/verdify-agentic-sprint")
}.freeze

mode = ARGV.first || "--check"
unless %w[--check --repair].include?(mode)
  warn "Usage: ruby scripts/setup-agent-hosts.rb [--check|--repair]"
  exit 2
end

def expected_target_for(link_path)
  Pathname.new("../../skills/verdify-agentic-sprint")
end

def valid_link?(link_path)
  link_path.exist? && link_path.realpath == CANONICAL_SKILL.realpath
rescue Errno::ENOENT
  false
end

errors = []

LINKS.each do |host, link_path|
  if valid_link?(link_path)
    puts "#{host}: ok #{link_path.relative_path_from(ROOT)}"
    next
  end

  if mode == "--check"
    errors << "#{host}: missing or invalid skill link at #{link_path.relative_path_from(ROOT)}"
    next
  end

  FileUtils.mkdir_p(link_path.dirname)
  if link_path.exist? && !link_path.symlink?
    errors << "#{host}: #{link_path.relative_path_from(ROOT)} exists and is not a symlink; move it before repair"
    next
  end

  FileUtils.rm_f(link_path) if link_path.symlink?
  File.symlink(expected_target_for(link_path).to_s, link_path)

  if valid_link?(link_path)
    puts "#{host}: repaired #{link_path.relative_path_from(ROOT)}"
  else
    errors << "#{host}: repair failed for #{link_path.relative_path_from(ROOT)}"
  end
end

if errors.any?
  warn errors.join("\n")
  exit 1
end

puts "Agent host skill links are ready."
