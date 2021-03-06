class CivicProject

  # Valid :TYPE values.
  # Ordering here used by the <=> operator.
  #
  VALID_TYPES = [
    "web application",
    "mobile application",
    "desktop application",
    "website",
    "document",
    "web service",
    "dataset",
  ].freeze

  # Valid :STATUS values.
  # Ordering here used by the <=> operator.
  #
  VALID_STATUSES = [
    "deployed",
    "beta",
    "in development",
    "ideation",
    "archival",
  ].freeze

  # Definition of data fields, and validations that will be performed against values.
  #
  FIELDS = {
    :KEY => {:REQUIRED => true, :TYPE => :SCALAR},
    :NAME => {:REQUIRED => true, :TYPE => :SCALAR},
    :DESCRIPTION => {:REQUIRED => true, :TYPE => :SCALAR, :MATCHES => %r{\.$}},
    :ACCESS_AT => {:TYPE => :SCALAR, :MATCHES => %r{^https?://}},
    :PROJECT_AT => {:TYPE => :SCALAR, :MATCHES => %r{^https?://}},
    :TYPE => {:REQUIRED => true, :TYPE => :SCALAR, :VALUES => VALID_TYPES},
    :STATUS => {:REQUIRED => true, :TYPE => :SCALAR, :VALUES => VALID_STATUSES},
    :CATEGORIES => {:TYPE => :LIST},
    :CONTACT => {:TYPE => :SCALAR},
  }.freeze

  class ValidationError < RuntimeError
  end

  def initialize(params = {})
    @fields = {}
    params.each do |field, value|
      self[field] = value
    end

    FIELDS.each do |field, validations|
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
    a = a.to_h unless a.instance_of?(Hash)
    key = File.basename(filename, ".yml")
    new(a.merge(:KEY => key))
  end


  def self.load_dir(dirname)
    a = Dir["#{dirname}/*.yml"].map {|filename| load_yml(filename)}.sort
    raise "no project files found in directory \"#{dirname}\"" if a.empty?
    a
  end


  # Convert a field name (such as "Description") to a canonicalized, symbolic value (such as :DESCRIPTION)
  def self.canonicalize_key(field)
    key = field.to_s.upcase.to_sym
    raise ValidationError, "unknown field \"#{field}\"" unless FIELDS.include?(key)
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
      self.class.validate_value!(value, FIELDS[key])
    rescue ValidationError => e
      raise ValidationError, "#{e} for field #{field}"
    end
    @fields[key] = value
  end

  def is_type?(type)
    self[:TYPE] == type.downcase
  end

  def is_status?(status)
    self[:STATUS] == status.downcase
  end

  def type_index
    VALID_TYPES.find_index(self[:TYPE])
  end

  def status_index
    VALID_STATUSES.find_index(self[:STATUS])
  end

  def to_h
    @fields.freeze
  end

  # Produce content of this project as a list: [[key, value], [key, value] ...]
  def to_list
    @fields.to_a.map {|a| [a[0].to_s.downcase, a[1]]}
  end

  def <=>(b)

    a1 = self.type_index || 9999
    b1 = b.type_index || 9999
    c = (a1 <=> b1)
    return c unless c == 0

    a1 = self.status_index || 9999
    b1 = b.status_index || 9999
    c = (a1 <=> b1)
    return c unless c == 0

    self[:NAME] <=> b[:NAME]
  end

end # CivicProject
