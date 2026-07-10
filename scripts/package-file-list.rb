#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "open3"
require "optparse"

EXCLUDED_ROOTS = %w[
  .git
  .agent-skills
  .agent-workflow
  dist
  node_modules
].freeze
EXCLUDED_FILES = %w[MANIFEST.sha256].freeze
SUPPORTED_MODES = %w[100644 100755 120000].freeze

options = {null: false, stage: nil, tree: false}
parser = OptionParser.new do |opts|
  opts.banner = "Usage: scripts/package-file-list.rb [--null] [--stage DIR] [--tree] [SOURCE]"
  opts.on("-0", "--null", "Separate paths with NUL bytes") { options[:null] = true }
  opts.on("--stage DIR", "Copy the selected files into an empty directory") { |dir| options[:stage] = dir }
  opts.on("--tree", "Select an already-exported tree instead of a Git index") { options[:tree] = true }
end
parser.parse!
abort parser.to_s if ARGV.length > 1

root = File.realpath(ARGV.fetch(0, File.expand_path("..", __dir__)))

excluded_path = lambda do |path|
  EXCLUDED_FILES.include?(path) || EXCLUDED_ROOTS.any? do |excluded_root|
    path == excluded_root || path.start_with?("#{excluded_root}/")
  end
end

entries = if options[:tree]
  Dir.glob("**/*", File::FNM_DOTMATCH, base: root).filter_map do |path|
    next if path == "." || excluded_path.call(path)

    stat = File.lstat(File.join(root, path))
    next if stat.directory?
    abort "exported tree path is not a regular file or symlink: #{path}" unless stat.file? || stat.symlink?
    mode = stat.symlink? ? "120000" : (stat.executable? ? "100755" : "100644")
    [path, mode]
  end
else
  git_root, git_error, git_status = Open3.capture3("git", "-C", root, "rev-parse", "--show-toplevel")
  abort "package source is not a Git worktree: #{root}\n#{git_error}" unless git_status.success?
  abort "package source must be the Git worktree root: #{root}" unless File.realpath(git_root.strip) == root

  index, index_error, index_status = Open3.capture3("git", "-C", root, "ls-files", "--cached", "--stage", "-z")
  abort "could not read the Git index for #{root}: #{index_error}" unless index_status.success?

  index.split("\0", -1).filter_map do |record|
    next if record.empty?

    match = record.match(/\A(\d{6}) [0-9a-f]+ ([0-3])\t(.*)\z/m)
    abort "could not parse Git index entry: #{record.inspect}" unless match

    mode, stage, path = match.captures
    abort "unmerged Git index entry is not packageable: #{path}" unless stage == "0"
    abort "unsafe tracked path is not packageable: #{path.inspect}" if path.empty? || path.start_with?("/") || path.split("/").include?("..")

    next if excluded_path.call(path)

    abort "unsupported tracked file mode #{mode} for #{path}" unless SUPPORTED_MODES.include?(mode)
    [path, mode]
  end
end

entries.sort_by!(&:first)

if options[:stage]
  destination = File.expand_path(options[:stage])
  FileUtils.mkdir_p(destination)
  abort "stage directory must be empty: #{destination}" unless Dir.empty?(destination)

  entries.each do |path, mode|
    source = File.join(root, path)
    target = File.join(destination, path)
    stat = File.lstat(source)
    expected_symlink = mode == "120000"
    abort "tracked file type does not match the Git index: #{path}" unless stat.symlink? == expected_symlink
    abort "tracked path is not a regular file or symlink: #{path}" unless stat.file? || stat.symlink?

    FileUtils.mkdir_p(File.dirname(target))
    if stat.symlink?
      File.symlink(File.readlink(source), target)
    else
      FileUtils.copy_file(source, target, true)
      File.chmod(stat.mode & 0o7777, target)
    end
  end
end

separator = options[:null] ? "\0" : "\n"
STDOUT.write(entries.map(&:first).join(separator))
STDOUT.write(separator) unless entries.empty?
