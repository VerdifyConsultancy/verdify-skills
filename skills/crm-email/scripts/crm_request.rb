#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"
require "net/http"
require "optparse"
require "pathname"
require "uri"

options = {
  base_url: ENV.fetch("VERDIFY_CRM_BASE_URL", "https://crm.verdify.ai"),
  method: "GET",
  path: nil,
  body: nil,
  dry_run: false
}

parser = OptionParser.new do |o|
  o.banner = "Usage: crm_request.rb --path PATH [--method GET|POST|PATCH|PUT|DELETE] [--body FILE] [--base-url URL] [--dry-run]"
  o.on("--base-url URL", "CRM base URL") { |v| options[:base_url] = v }
  o.on("--method METHOD", "HTTP method") { |v| options[:method] = v.upcase }
  o.on("--path PATH", "API path beginning with /") { |v| options[:path] = v }
  o.on("--body FILE", "JSON request body file") { |v| options[:body] = v }
  o.on("--dry-run", "Validate and print redacted request metadata without sending") { options[:dry_run] = true }
  o.on("-h", "--help") { puts o; exit 0 }
end
parser.parse!

abort "--path is required" if options[:path].to_s.empty?
abort "--path must begin with /" unless options[:path].start_with?("/")

allowed_methods = %w[GET POST PATCH PUT DELETE]
abort "unsupported method #{options[:method]}" unless allowed_methods.include?(options[:method])

base = URI(options[:base_url])
abort "--base-url must use http or https" unless %w[http https].include?(base.scheme) && base.host
uri = URI.join("#{base}/", options[:path].sub(%r{\A/+}, ""))
body_content = nil
if options[:body]
  body_path = Pathname.new(options[:body])
  abort "body file not found: #{body_path}" unless body_path.file?
  body_content = body_path.read
  JSON.parse(body_content)
end

if options[:dry_run]
  result = {
    "dry_run" => true,
    "method" => options[:method],
    "path" => options[:path],
    "origin" => "#{uri.scheme}://#{uri.host}#{uri.port == uri.default_port ? '' : ":#{uri.port}"}",
    "body_bytes" => body_content&.bytesize || 0,
    "body_sha256" => body_content && Digest::SHA256.hexdigest(body_content)
  }
  puts JSON.pretty_generate(result)
  exit 0
end

abort "VERDIFY_CRM_API_KEY is required" if ENV["VERDIFY_CRM_API_KEY"].to_s.empty?

request_class = Net::HTTP.const_get(options[:method].capitalize)
request = request_class.new(uri)
request["Authorization"] = "Bearer #{ENV.fetch('VERDIFY_CRM_API_KEY')}"
request["Accept"] = "application/json"

if body_content
  request["Content-Type"] = "application/json"
  request.body = body_content
end

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
  http.request(request)
end

result = {
  "method" => options[:method],
  "path" => options[:path],
  "status" => response.code.to_i,
  "content_type" => response["content-type"],
  "body" => begin
    JSON.parse(response.body.to_s)
  rescue JSON::ParserError
    response.body.to_s
  end
}

puts JSON.pretty_generate(result)
exit(response.code.to_i.between?(200, 299) ? 0 : 1)
