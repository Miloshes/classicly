module SeoHelper # Please don't put into application helper
  
  def seo_admin_element_name(element)
    case element.class.to_s
    when 'Book', 'Audiobook'
      element.pretty_title
    when 'Collection'
      element.name
    when 'SeoSlug'
      element.seoable.respond_to?(:name) ? element.seoable.name : element.seoable.pretty_title
    else
      nil
    end
  end
  
  def seo_admin_element_slug(element)
    case element.class.to_s
    when 'Book', 'Audiobook', 'Collection'
      element.cached_slug
    when 'SeoSlug'
      element.slug
    else
      nil
    end
  end

  def seo_admin_open_graph_type(element)
    return element.seoable_type if element.is_a?(SeoSlug)
    return "#{element.book_type.capitalize} Collection" if element.is_a?(Collection)
    element.class.to_s
  end
  
  def seo_front_end_title_for_collection(collection)
    prefix = collection.collection_type == 'collection' ? "#{collection.name} - " : "#{collection.name} Books - "
    suffix = "Download Free Books, Read Online, and More"
    if [prefix, suffix].map(&:length).reduce(:+) <= 70
      return prefix + suffix
    end
    prefix
  end

  def seo_front_end_title_helper(element)
    if element.seo_info
      element.seo_info.title
    elsif element.is_a?(SeoSlug)
      element.slug
    else
      element.respond_to?(:pretty_title) ? element.pretty_title : seo_front_end_title_for_collection(element)
    end
  end
end