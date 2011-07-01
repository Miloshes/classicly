class SeoDefault < ActiveRecord::Base
  def self.parse_default_value(attribute, object)
    klass = object.class.to_s
    default_seo_object_array = case klass
    when 'Collection'
      collection_type = [object.book_type, object.collection_type].join('-')
      SeoDefault.where(:object_type => klass, :object_attribute => attribute.to_s, :collection_type => collection_type)
    when 'SeoSlug'
      SeoDefault.where(:object_type => klass, :object_attribute => attribute.to_s, :format => object.format)
    else
      SeoDefault.where(:object_type => klass, :object_attribute => attribute.to_s)
    end
    return nil if default_seo_object_array.first.nil? # this is to save the app whenever the default has not been set.
    string_to_parse = default_seo_object_array.first.default_value
    result = string_to_parse.scan /\$[\(]\w+.\w+[\)]/
    result.each do |expression|
      method_to_call = expression.scan(/\w+.\w+/).first
      substitute_for = object.parse_attribute_for_seo(method_to_call)
      string_to_parse.gsub!(expression, substitute_for) unless substitute_for.nil?
    end
    string_to_parse
  end

  def self.parse_default_value_for_static_page(attribute, page)
    default_seo_object_array = SeoDefault.where(:object_type => page, :object_attribute => attribute.to_s)
    return nil if default_seo_object_array.first.nil? # this is to save the app whenever the default has not been set.
    default_seo_object_array.first.default_value
  end

  def is_default_value_valid?
    object = self.object_type.constantize.first
    SeoDefault.parse_default_value(self.object_attribute.to_sym, object).scan(/\$[\(]/).blank?
  end
end
