class FloatConverter
  def self.convert(value)
    value.gsub(" ", "").to_f unless (value.is_a?(Fixnum) || value.is_a?(Float))
  end
end
