module AFPD

  VALIDATIONS = {
    :KEY => {:REQUIRED => true, :TYPE => :SCALAR},
    :NAME => {:REQUIRED => true, :TYPE => :SCALAR},
    :DESCRIPTION => {:REQUIRED => true, :TYPE => :SCALAR},
    :ACCESS_AT => {:TYPE => :SCALAR, :MATCHES => %r{^https?://}},
    :PROJECT_AT => {:TYPE => :SCALAR, :MATCHES => %r{^https?://}},
    :TYPE => {:TYPE => :SCALAR, :VALUES => ["web application", "mobile application", "desktop application", "web service", "website", "dataset", "document"]},
    :STATUS => {:TYPE => :SCALAR, :VALUES => ["ideation", "in development", "beta", "deployed", "archival"]},
    :CATEGORIES => {:TYPE => :LIST},
    :CONTACTS => {:TYPE => :LIST},
  }.freeze

  class ValidationError < RuntimeError
  end

  class Project

    def initialize(params = {})
      @fields = {}
      params.each do |field, value|
        self[field] = value
      end

      VALIDATIONS.each do |field, validations|
        is_required = validations[:REQUIRED]
        if is_required
          value = self[field]
          if value.nil? || value.empty?
            raise ValidationError, "field \"#{field}\" cannot have empty value"
          end
        end
      end
    end


    def self.load_yml(filename)
      require "yaml"
      a = YAML.load_file(filename)
      key = File.basename(filename, ".yml")
      new(a.to_h.merge(:KEY => key))
    end


    def self.load_dir(dirname)
      Dir["#{dirname}/*.yml"].map {|filename| load_yml(filename)}
    end


    # Convert a field name (such as "Description") to a canonicalized, symbolic value (such as :DESCRIPTION)
    def self.canonicalize_key(field)
      key = field.to_s.upcase.to_sym
      raise ValidationError, "unknown field \"#{field}\"" unless VALIDATIONS.include?(key)
      key
    end

    # Apply a set of validations to a given value.
    #
    # Parameters:
    # * value - Field value that will be validated.
    # * validations - Hash of validations to perform.
    #
    # Possible validations are:
    # * :REQUIRED => flag - Value is required (not null, not empty) if flag is true
    # * :TYPE => {:SCALAR | :LIST}
    # * :VALUES => list
    # * :MATCHES => regexp
    #
    def self.validate_value!(value, validations)

      if value.nil? || value.empty?
        is_required = validations[:REQUIRED]
        raise ValidationError, "value cannot be empty" if is_required
        return
      end

      is_list_value = case value
      when Array
        true
      when String
      when Fixnum
      when True
      when False
      when NilClass
        false
      else
        raise ValidationError, "bad value type \"#{value.class}\""
      end

      case validations[:TYPE]
      when :SCALAR
        raise ValidationError, "scalar value required" if is_list_value
      when :LIST
        raise ValidationError, "list value required" unless is_list_value
      else
        raise ValidationError, "internal error - bad :TYPE specifier \"#{validations[:TYPE]}\""
      end

      allowed_values = validations[:VALUES]
      if allowed_values
        (value.kind_of?(Array) ? value : [value]).each do |v|
          raise ValidationError, "value \"#{v}\" not allowed" unless allowed_values.include?(v)
        end
      end

      match_expr = validations[:MATCHES]
      if match_expr
          raise ValidationError, "value \"#{value}\" does not match expected format" unless value =~ match_expr
      end

    end

    def [](field)
      key = self.class.canonicalize_key(field)
      @fields[key]
    end

    def []=(field, value)
      key = self.class.canonicalize_key(field)
      begin
        self.class.validate_value!(value, VALIDATIONS[key])
      rescue ValidationError => e
        raise ValidationError, "#{e} for field #{field}"
      end
      @fields[key] = value
    end

    def to_h
      @fields.freeze
    end

  end

end
