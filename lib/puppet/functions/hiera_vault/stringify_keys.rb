  # Stringify key:values so user sees expected results and nested objects
  def stringify_keys(value)
    case value
    when String
      raise ArgumentError, "Empty or blank string value found: '#{value}'" if value.strip.empty?
      value
    when Numeric, TrueClass, FalseClass
      value.to_s
    when Hash
      raise ArgumentError, "Empty hash found" if value.empty?
      value.to_h do |k, v|
        raise ArgumentError, "Nil value found for key '#{k}'" if v.nil?
        [k.to_s, stringify_keys(v)]
      end
    when Array
      raise ArgumentError, "Empty array found" if value.empty?
      value.map { |v| stringify_keys(v) }
    when NilClass
      raise ArgumentError, "Nil value found"
    else
      value
    end
  end