#!/usr/bin/env bash
set -euo pipefail

[[ $# -eq 1 ]] || { echo "Usage: scripts/verify-package.sh ARCHIVE.zip" >&2; exit 2; }
archive="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
[[ -f "$archive" ]] || { echo "archive not found: $archive" >&2; exit 2; }
for command in ruby unzip zipinfo; do
  command -v "$command" >/dev/null || { echo "$command is required to verify Verdify" >&2; exit 1; }
done

ruby -rdigest -rfileutils -ropen3 -rpathname -rtmpdir -e '
  archive = ARGV.fetch(0)

  def capture!(*command)
    stdout, stderr, status = Open3.capture3(*command)
    abort "#{command.join(" ")} failed: #{stderr.strip}" unless status.success?
    stdout
  end

  names = capture!("unzip", "-Z1", archive).lines(chomp: true)
  abort "archive is empty" if names.empty?
  abort "archive contains a member name with an embedded newline" if names.any?(&:empty?)
  duplicates = names.tally.select { |_, count| count > 1 }.keys
  abort "duplicate archive members: #{duplicates.sort.join(", ")}" unless duplicates.empty?

  info = capture!("zipinfo", "-l", archive).lines.filter_map do |line|
    fields = line.strip.split(/\s+/, 10)
    next unless fields.length == 10 && fields[0].match?(/\A[bcdlps-][rwxStTs-]{9}\z/)
    [fields[9], fields[0][0]]
  end
  abort "could not classify every archive member" unless info.map(&:first) == names
  types = info.to_h

  names.each do |name|
    abort "unsafe archive member: #{name.inspect}" if name.start_with?("/") || name.include?("\\")
    parts = name.delete_suffix("/").split("/", -1)
    abort "unsafe archive member: #{name.inspect}" if parts.empty? || parts.any? { |part| part.empty? || part == "." || part == ".." }
  end

  roots = names.map { |name| name.delete_suffix("/").split("/", 2).first }.uniq
  abort "archive must contain exactly one root directory" unless roots.length == 1
  root_name = roots.first
  manifest_member = "#{root_name}/MANIFEST.sha256"
  abort "MANIFEST.sha256 is missing or not regular" unless types[manifest_member] == "-"
  manifest = capture!("unzip", "-p", archive, manifest_member)

  manifest_entries = {}
  manifest.each_line(chomp: true) do |line|
    digest, path = line.split(/  /, 2)
    abort "invalid manifest line: #{line}" unless digest&.match?(/\A[0-9a-f]{64}\z/) && path
    abort "unsafe manifest path: #{path.inspect}" if path.start_with?("/") || path.include?("\\") || path.split("/", -1).any? { |part| part.empty? || part == "." || part == ".." }
    abort "duplicate manifest path: #{path}" if manifest_entries.key?(path)
    manifest_entries[path] = digest
  end
  abort "manifest is empty" if manifest_entries.empty?

  skill_names = manifest_entries.keys.filter_map do |path|
    match = path.match(%r{\Askills/([^/]+)/SKILL\.md\z})
    match && match[1]
  end.sort
  abort "expected 28 skill manifests, found #{skill_names.length}" unless skill_names.length == 28

  expected = {}
  manifest_entries.each_key { |path| expected["#{root_name}/#{path}"] = "-" }
  expected[manifest_member] = "-"
  skill_names.each do |skill|
    expected["#{root_name}/.agents/skills/#{skill}"] = "l"
    expected["#{root_name}/.claude/skills/#{skill}"] = "l"
  end
  expected.keys.each do |name|
    parts = name.split("/")
    (1...parts.length).each { |length| expected[parts.first(length).join("/") + "/"] = "d" }
  end

  missing = expected.keys - types.keys
  extra = types.keys - expected.keys
  wrong_type = (expected.keys & types.keys).select { |name| expected.fetch(name) != types.fetch(name) }
  unless missing.empty? && extra.empty? && wrong_type.empty?
    abort "archive member set differs: missing=#{missing.sort.inspect} extra=#{extra.sort.inspect} wrong_type=#{wrong_type.sort.inspect}"
  end

  Dir.mktmpdir("verdify-archive-") do |tmp|
    _stdout, stderr, status = Open3.capture3("unzip", "-q", archive, "-d", tmp)
    abort "archive extraction failed: #{stderr.strip}" unless status.success?
    root = Pathname.new(tmp).join(root_name)
    manifest_entries.each do |relative, digest|
      path = root.join(relative)
      abort "manifest member is not a regular file: #{relative}" unless path.file? && !path.symlink?
      actual = Digest::SHA256.file(path).hexdigest
      abort "checksum mismatch: #{relative}" unless actual == digest
    end
    skill_names.each do |skill|
      [root.join(".agents/skills", skill), root.join(".claude/skills", skill)].each do |link|
        abort "expected discovery symlink: #{link.relative_path_from(root)}" unless link.symlink?
        abort "unsafe discovery symlink target: #{link}" unless link.readlink.to_s == "../../skills/#{skill}"
      end
    end
  end

  puts "Package verification passed: #{archive}"
' "$archive"
