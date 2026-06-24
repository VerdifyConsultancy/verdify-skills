# frozen_string_literal: true

require "date"
require "ipaddr"
require "uri"

module Verdify
  class SchemaValidator
    TYPE_CHECKS = {
      "object" => ->(v) { v.is_a?(Hash) },
      "array" => ->(v) { v.is_a?(Array) },
      "string" => ->(v) { v.is_a?(String) },
      "integer" => ->(v) { v.is_a?(Integer) && !v.is_a?(TrueClass) && !v.is_a?(FalseClass) },
      "number" => ->(v) { v.is_a?(Numeric) && !v.is_a?(TrueClass) && !v.is_a?(FalseClass) },
      "boolean" => ->(v) { v == true || v == false },
      "null" => ->(v) { v.nil? }
    }.freeze
    SUPPORTED_FORMATS = %w[date-time date time duration email hostname ipv4 ipv6 uri uri-reference uuid].freeze
    UUID_PATTERN = /\A[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i
    EMAIL_PATTERN = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/
    HOSTNAME_LABEL_PATTERN = /\A[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\z/i

    def self.load_document(path)
      path = Pathname.new(path)
      case path.extname.downcase
      when ".json"
        JSON.parse(path.read)
      when ".yaml", ".yml"
        YAML.safe_load(path.read, permitted_classes: [], aliases: false)
      else
        raise Error, "Unsupported artifact type: #{path}"
      end
    rescue JSON::ParserError, Psych::Exception => e
      raise Error, "Could not parse #{path}: #{e.message}"
    end

    def self.validate_file(document_path, schema_path)
      document = load_document(document_path)
      schema = load_document(schema_path)
      new.validate(document, schema)
    end

    def validate(value, schema, path = "$", root_schema = schema, ref_stack = [])
      errors = []
      return errors if schema == true
      return ["#{path}: boolean schema false does not allow value"] if schema == false
      return errors unless schema.is_a?(Hash)

      if schema.key?("$ref")
        ref = schema["$ref"].to_s
        if ref_stack.include?(ref)
          errors << "#{path}: recursive $ref #{ref.inspect} is not supported"
        elsif (referenced_schema = resolve_ref(ref, root_schema))
          errors.concat(validate(value, referenced_schema, path, root_schema, ref_stack + [ref]))
        else
          errors << "#{path}: unresolved or unsupported $ref #{ref.inspect}"
        end
      end

      if schema.key?("const") && value != schema["const"]
        errors << "#{path}: expected constant #{schema['const'].inspect}, got #{value.inspect}"
      end

      if schema["enum"].is_a?(Array) && !schema["enum"].include?(value)
        errors << "#{path}: expected one of #{schema['enum'].inspect}, got #{value.inspect}"
      end

      if schema.key?("type")
        types = Array(schema["type"]).map(&:to_s)
        unsupported = types - TYPE_CHECKS.keys
        unless unsupported.empty?
          errors << "#{path}: unsupported schema type #{unsupported.join(' or ')}"
          return errors
        end
        unless types.any? { |type| TYPE_CHECKS.fetch(type, ->(_v) { true }).call(value) }
          errors << "#{path}: expected type #{types.join(' or ')}, got #{ruby_type(value)}"
          return errors
        end
      end

      if value.is_a?(Hash)
        required = Array(schema["required"])
        required.each do |key|
          errors << "#{path}: missing required property #{key.inspect}" unless value.key?(key)
        end

        if schema["dependentRequired"].is_a?(Hash)
          schema["dependentRequired"].each do |key, dependents|
            next unless value.key?(key)

            Array(dependents).each do |dependent|
              errors << "#{path}: property #{key.inspect} requires property #{dependent.inspect}" unless value.key?(dependent)
            end
          end
        end

        properties = schema["properties"].is_a?(Hash) ? schema["properties"] : {}
        pattern_properties = schema["patternProperties"].is_a?(Hash) ? compile_pattern_properties(schema["patternProperties"]) : []
        value.each do |key, child|
          matched_pattern = false
          if properties.key?(key)
            errors.concat(validate(child, properties[key], "#{path}.#{key}", root_schema, ref_stack))
          end
          pattern_properties.each do |pattern, subschema|
            next unless pattern.match?(key)

            matched_pattern = true
            errors.concat(validate(child, subschema, "#{path}.#{key}", root_schema, ref_stack))
          end
          if !properties.key?(key) && !matched_pattern && schema["additionalProperties"] == false
            errors << "#{path}: unexpected property #{key.inspect}"
          elsif !properties.key?(key) && !matched_pattern && schema.key?("additionalProperties")
            errors.concat(validate(child, schema["additionalProperties"], "#{path}.#{key}", root_schema, ref_stack))
          end
        end
      end

      if value.is_a?(Array)
        prefix_count = 0
        if schema["minItems"] && value.length < schema["minItems"].to_i
          errors << "#{path}: expected at least #{schema['minItems']} items, got #{value.length}"
        end
        if schema["maxItems"] && value.length > schema["maxItems"].to_i
          errors << "#{path}: expected at most #{schema['maxItems']} items, got #{value.length}"
        end
        if schema["uniqueItems"] && value.uniq.length != value.length
          errors << "#{path}: items must be unique"
        end
        if schema["prefixItems"].is_a?(Array)
          schema["prefixItems"].each_with_index do |subschema, index|
            next unless index < value.length

            errors.concat(validate(value[index], subschema, "#{path}[#{index}]", root_schema, ref_stack))
          end
          prefix_count = schema["prefixItems"].length
        end
        if schema.key?("items")
          value.each_with_index do |child, index|
            next if index < prefix_count

            errors.concat(validate(child, schema["items"], "#{path}[#{index}]", root_schema, ref_stack))
          end
        end
      end

      if value.is_a?(String)
        errors << "#{path}: shorter than minLength #{schema['minLength']}" if schema["minLength"] && value.length < schema["minLength"].to_i
        errors << "#{path}: longer than maxLength #{schema['maxLength']}" if schema["maxLength"] && value.length > schema["maxLength"].to_i
        if schema["pattern"]
          pattern = Regexp.new(schema["pattern"])
          errors << "#{path}: does not match #{schema['pattern'].inspect}" unless pattern.match?(value)
        end
        if schema["format"]
          errors << "#{path}: does not match format #{schema['format'].inspect}" unless valid_format?(value, schema["format"].to_s)
        end
      end

      if value.is_a?(Numeric)
        errors << "#{path}: below minimum #{schema['minimum']}" if schema.key?("minimum") && value < schema["minimum"]
        errors << "#{path}: above maximum #{schema['maximum']}" if schema.key?("maximum") && value > schema["maximum"]
      end

      if schema["allOf"].is_a?(Array)
        schema["allOf"].each { |subschema| errors.concat(validate(value, subschema, path, root_schema, ref_stack)) }
      end

      if schema["anyOf"].is_a?(Array)
        matches = schema["anyOf"].count { |subschema| validate(value, subschema, path, root_schema, ref_stack).empty? }
        errors << "#{path}: does not satisfy any allowed schema" if matches.zero?
      end

      if schema["oneOf"].is_a?(Array)
        matches = schema["oneOf"].count { |subschema| validate(value, subschema, path, root_schema, ref_stack).empty? }
        errors << "#{path}: expected exactly one matching schema, got #{matches}" unless matches == 1
      end

      if schema["if"].is_a?(Hash)
        condition_matches = validate(value, schema["if"], path, root_schema, ref_stack).empty?
        if condition_matches && schema["then"].is_a?(Hash)
          errors.concat(validate(value, schema["then"], path, root_schema, ref_stack))
        elsif !condition_matches && schema["else"].is_a?(Hash)
          errors.concat(validate(value, schema["else"], path, root_schema, ref_stack))
        end
      end

      errors
    rescue RegexpError => e
      ["#{path}: invalid schema pattern: #{e.message}"]
    end

    private

    def compile_pattern_properties(patterns)
      patterns.map { |pattern, subschema| [Regexp.new(pattern), subschema] }
    end

    def resolve_ref(ref, root_schema)
      return nil unless ref.start_with?("#")

      resolve_json_pointer(root_schema, ref.delete_prefix("#"))
    end

    def resolve_json_pointer(root, pointer)
      return root if pointer == ""
      return nil unless pointer.start_with?("/")

      pointer.split("/").drop(1).reduce(root) do |current, token|
        key = token.gsub("~1", "/").gsub("~0", "~")
        if current.is_a?(Hash) && current.key?(key)
          current[key]
        elsif current.is_a?(Array) && key.match?(/\A\d+\z/) && key.to_i < current.length
          current[key.to_i]
        else
          return nil
        end
      end
    end

    def valid_format?(value, format)
      return false unless SUPPORTED_FORMATS.include?(format)

      case format
      when "date-time" then parse_time(value)
      when "date" then parse_date(value)
      when "time" then parse_time_of_day(value)
      when "duration" then value.match?(/\AP(?:\d+Y)?(?:\d+M)?(?:\d+D)?(?:T(?:\d+H)?(?:\d+M)?(?:\d+(?:\.\d+)?S)?)?\z/) && value != "P"
      when "email" then value.match?(EMAIL_PATTERN)
      when "hostname" then valid_hostname?(value)
      when "ipv4" then parse_ip(value)&.ipv4?
      when "ipv6" then parse_ip(value)&.ipv6?
      when "uri" then valid_uri?(value, absolute: true)
      when "uri-reference" then valid_uri?(value, absolute: false)
      when "uuid" then value.match?(UUID_PATTERN)
      else false
      end
    end

    def parse_time(value)
      Time.iso8601(value)
      true
    rescue ArgumentError
      false
    end

    def parse_date(value)
      Date.iso8601(value)
      true
    rescue ArgumentError
      false
    end

    def parse_time_of_day(value)
      Time.iso8601("2000-01-01T#{value}")
      true
    rescue ArgumentError
      false
    end

    def parse_ip(value)
      IPAddr.new(value)
    rescue IPAddr::InvalidAddressError
      nil
    end

    def valid_uri?(value, absolute:)
      uri = URI.parse(value)
      return false if absolute && uri.scheme.to_s.empty?

      true
    rescue URI::InvalidURIError
      false
    end

    def valid_hostname?(value)
      return false if value.empty? || value.length > 253 || value.start_with?(".") || value.end_with?(".")

      value.split(".").all? { |label| label.match?(HOSTNAME_LABEL_PATTERN) }
    end

    def ruby_type(value)
      case value
      when Hash then "object"
      when Array then "array"
      when String then "string"
      when Integer then "integer"
      when Numeric then "number"
      when TrueClass, FalseClass then "boolean"
      when NilClass then "null"
      else value.class.name
      end
    end
  end
end
