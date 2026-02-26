  # Stringify key:values so user sees expected results and nested objects
  def stringify_keys(value)
    case value
    when String
      if value.empty? || value.strip.empty?
        raise ArgumentError, "Empty or blank string value found: '#{value}'"
      end
      value
    when Numeric, TrueClass, FalseClass
      value.to_s
    when Hash
      if value.empty?
        raise ArgumentError, "Empty hash found"
      end
      result = {}
      value.each_pair do |k, v|
        if v.nil?
          raise ArgumentError, "Nil value found for key '#{k}'"
        end
        result[k.to_s] = stringify_keys v
      end
      result
    when Array
      if value.empty?
        raise ArgumentError, "Empty array found"
      end
      value.map { |v| stringify_keys v }
    when NilClass
      raise ArgumentError, "Nil value found"
    else
      value
    end
  end