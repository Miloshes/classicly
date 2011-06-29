class SeoDefault < ActiveRecord::Base
  def self.parse_default_value(attribute, object)
    klass = object.class.to_s
    default_seo_object = SeoDefault.where(:object_type => klass, :object_attribute => attribute.to_s).first
    string_to_parse = default_seo_object.default_value
    result = string_to_parse.scan /\$[\(]\w+.\w+[\)]/
    result.each do |expression|
      method_to_call = expression.scan(/\w+.\w+/).first
      substitute_for = object.parse_attribute_for_seo(method_to_call)
      string_to_parse.gsub!(expression, substitute_for) unless substitute_for.nil?
    end
    string_to_parse
  end
  
  def is_default_value_valid?
    object = self.object_type.constantize.first
    SeoDefault.parse_default_value(self.object_attribute.to_sym, object).scan(/\$[\(]/).blank?
  end
end
