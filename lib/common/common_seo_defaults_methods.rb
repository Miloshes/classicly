module CommonSeoDefaultsMethods
  def parse_attribute_for_seo(attribute_string)
    substrings = attribute_string.split('.')
    if substrings.size == 2 # calling an association
      association = self.send(substrings.first.to_sym) if self.respond_to?(substrings.first.to_sym)
      association.send(substrings.last.to_sym) if association && association.respond_to?(substrings.last.to_sym)
    else
      self.send(attribute_string.to_sym) if self.respond_to?(attribute_string.to_sym)
    end
  end
end
