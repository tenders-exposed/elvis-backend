class IntegerConverter
  def self.convert(value)
    value.strip.gsub(" ", "").to_f
  end
end
