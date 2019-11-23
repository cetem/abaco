class Object
  def to_bool
    self == true || self.to_s.match?(/(true|t|yes|y|1)$/i)
  end
end
