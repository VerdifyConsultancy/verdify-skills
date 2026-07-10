#!/usr/bin/env ruby
# frozen_string_literal: true

require "base64"
require "digest"
require "json"
require "optparse"
require "pathname"
require "rubygems/package"
require "zlib"

options = { tarball: nil, sidecar: nil, installed_root: nil }
OptionParser.new do |o|
  o.banner = "Usage: ruby scripts/verify-npm-tarball.rb (--tarball FILE --sidecar FILE | --installed-root PATH)"
  o.on("--tarball FILE", "Exact npm tarball to verify") { |v| options[:tarball] = Pathname.new(v).expand_path }
  o.on("--sidecar FILE", "Release-candidate sidecar") { |v| options[:sidecar] = Pathname.new(v).expand_path }
  o.on("--installed-root PATH", "Extracted or installed npm package root") { |v| options[:installed_root] = Pathname.new(v).expand_path }
end.parse!

def fail!(message)
  warn "npm artifact verification failed: #{message}"
  exit 1
end

def package_identity(root)
  package_path = root.join("package.json")
  version_path = root.join("VERSION")
  fail!("package.json is missing") unless package_path.file?
  fail!("VERSION is missing") unless version_path.file?

  package = JSON.parse(package_path.read)
  version = version_path.read.strip
  fail!("package.json and VERSION disagree") unless package.fetch("version") == version
  [package, version]
rescue JSON::ParserError => e
  fail!("package.json is invalid: #{e.message}")
end

def verify_installed_root!(root)
  package, version = package_identity(root)
  expected_test = "ruby scripts/verify-npm-tarball.rb --installed-root ."
  fail!("installed package advertises an unrunnable test command") unless package.dig("scripts", "test") == expected_test
  fail!("installed verifier is missing") unless root.join("scripts/verify-npm-tarball.rb").file?

  package.fetch("bin").each_value do |relative|
    target = root.join(relative)
    fail!("declared command is missing: #{relative}") unless target.file?
  end

  skill_files = Dir[root.join("skills/*/SKILL.md")].sort
  fail!("expected 28 installed skills, found #{skill_files.length}") unless skill_files.length == 28
  skill_files.each do |path|
    metadata_version = File.read(path)[/^  version: ["']([^"']+)["']$/, 1]
    fail!("#{Pathname.new(path).relative_path_from(root)} metadata.version is not #{version}") unless metadata_version == version
  end

  puts "Installed npm package verification passed for #{package.fetch('name')}@#{version}"
end

if options[:installed_root]
  fail!("--installed-root cannot be combined with tarball options") if options[:tarball] || options[:sidecar]
  verify_installed_root!(options.fetch(:installed_root))
  exit 0
end

begin
tarball = options[:tarball]
sidecar_path = options[:sidecar]
fail!("--tarball and --sidecar are required") unless tarball && sidecar_path
fail!("tarball is missing: #{tarball}") unless tarball.file?
fail!("sidecar is missing: #{sidecar_path}") unless sidecar_path.file?

sidecar = JSON.parse(sidecar_path.read)
fail!("unsupported sidecar schema_version") unless sidecar["schema_version"] == "1.0"
fail!("source commit is invalid") unless sidecar.dig("source", "commit").to_s.match?(/\A[0-9a-f]{40}\z/)
fail!("source clean flag is missing") unless [true, false].include?(sidecar.dig("source", "clean"))
fail!("pack-count proof must be exactly one") unless sidecar.dig("build", "npm_pack_invocations") == 1
fail!("package-file-list blob identity is invalid") unless sidecar.dig("build", "package_file_list_blob").to_s.match?(/\A[0-9a-f]{40}\z/)

expected_sha256 = sidecar.dig("tarball", "sha256")
expected_sha512 = sidecar.dig("tarball", "sha512")
actual_sha256 = Digest::SHA256.file(tarball).hexdigest
actual_sha512 = Digest::SHA512.file(tarball).hexdigest
actual_integrity = "sha512-#{Base64.strict_encode64([actual_sha512].pack('H*'))}"
fail!("tarball filename does not match sidecar") unless tarball.basename.to_s == sidecar.dig("tarball", "filename")
fail!("tarball size does not match sidecar") unless tarball.size == sidecar.dig("tarball", "size")
fail!("tarball SHA-256 does not match sidecar") unless actual_sha256 == expected_sha256
fail!("tarball SHA-512 does not match sidecar") unless actual_sha512 == expected_sha512
fail!("tarball npm integrity does not match sidecar") unless actual_integrity == sidecar.dig("tarball", "integrity")

expected_entries = sidecar.dig("tarball", "files")
fail!("sidecar file inventory is missing") unless expected_entries.is_a?(Array) && !expected_entries.empty?
expected = expected_entries.to_h do |entry|
  path = entry.fetch("path")
  fail!("unsafe expected npm path: #{path.inspect}") if path.empty? || path.start_with?("/") || path.include?("\\") || path.split("/").any? { |part| part.empty? || part == "." || part == ".." }
  ["package/#{path}", entry]
end
fail!("sidecar file inventory contains duplicate paths") unless expected.length == expected_entries.length

actual = {}
contents = {}
Zlib::GzipReader.open(tarball.to_s) do |gzip|
  Gem::Package::TarReader.new(gzip) do |tar|
    tar.each do |entry|
      name = entry.full_name
      fail!("unsafe npm tar member: #{name.inspect}") if name.empty? || name.start_with?("/") || name.include?("\\") || name.split("/").any? { |part| part.empty? || part == "." || part == ".." }
      fail!("duplicate npm tar member: #{name}") if actual.key?(name)
      fail!("npm tar member is not a regular file: #{name}") unless entry.file?
      actual[name] = { "size" => entry.header.size, "mode" => entry.header.mode }
      contents[name] = entry.read if name == "package/package.json" || name == "package/VERSION" || name.match?(%r{\Apackage/skills/[^/]+/SKILL\.md\z})
    end
  end
end

missing = expected.keys - actual.keys
extra = actual.keys - expected.keys
fail!("npm tar member set differs (missing=#{missing.sort.inspect}, extra=#{extra.sort.inspect})") unless missing.empty? && extra.empty?
expected.each do |name, metadata|
  fail!("npm tar member size differs: #{name}") unless actual.fetch(name).fetch("size") == metadata.fetch("size")
  fail!("npm tar member mode differs: #{name}") unless actual.fetch(name).fetch("mode") == metadata.fetch("mode")
end

package = JSON.parse(contents.fetch("package/package.json"))
version = contents.fetch("package/VERSION").strip
fail!("tarball package identity disagrees with sidecar") unless package.fetch("name") == sidecar.dig("package", "name") && package.fetch("version") == sidecar.dig("package", "version")
fail!("tarball VERSION disagrees with package.json") unless version == package.fetch("version")
fail!("tarball gitHead disagrees with clean source") unless package.fetch("gitHead") == sidecar.dig("source", "commit")
skill_contents = contents.select { |name, _| name.match?(%r{\Apackage/skills/[^/]+/SKILL\.md\z}) }
fail!("expected 28 skills in npm tarball, found #{skill_contents.length}") unless skill_contents.length == 28
skill_contents.each do |name, content|
  metadata_version = content[/^  version: ["']([^"']+)["']$/, 1]
  fail!("#{name} metadata.version is not #{version}") unless metadata_version == version
end

puts "Exact npm tarball verification passed: #{tarball}"
rescue JSON::ParserError, KeyError, Zlib::GzipFile::Error, Gem::Package::TarInvalidError => e
  fail!(e.message)
end
