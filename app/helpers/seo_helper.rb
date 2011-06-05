module SeoHelper # Please don't put into application helper
  
  def fb_open_graph_metadata(config={}, seo_info = nil)
    content_tag(:meta, nil, {:property => "og:title", :content => seo_info.try(:og_title) || config[:title] || "Classicly"}) +
    content_tag(:meta, nil, {:property => "og:type", :content => config[:type] || "website"}) +
    content_tag(:meta, nil, {:property => "og:url", :content => config[:url] || "http://www.classicly.com"}) +
    content_tag(:meta, nil, {:property => "og:image", :content => config[:image] || "http://www.classicly.com/images/logo.png"}) +
    content_tag(:meta, nil, {:property => "og:site_name", :content => "Classicly"}) +
    content_tag(:meta, nil, {:property => "fb:app_id", :content => Facebook::APP_ID}) +
    content_tag(:meta, nil, {:property => "og:description", :content => seo_info.try(:og_description) || config[:description] || "23,469 of the world's greatest free books, available for free in PDF,  Kindle, Sony Reader, iBooks, and more. You can also read online!"})
  end
  
  def meta_description_for_element(element)
    case element.class.to_s
    when 'Collection'
      case element.collection_type
      when 'collection'
        "%s- the ultimate literature collection. Dozens of hand-picked books for free download as PDF, Kindle, Sony Reader, iBooks, and more. You can also read online!" % element.name
      when 'author'
        "The world's greatest collection of books by %s. Download free books, read online, or check out %s quotes and a hand-picked collection of featured titles." % ([element.name] * 2)
      end
    when 'Book', 'Audiobook'
      "Download %s for free on Classicly - available as Kindle, PDF, Sony Reader, iBooks and more, or simply read online to your heart's content." % element.pretty_title
    end
  end
  
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
  
  def seo_front_end_meta_description_text(element)
    if element.seo_info
      description = element.seo_info.meta_description
    else
      element = element.seoable if element.is_a? SeoSlug
      meta_description_for_element(element)
    end
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
    elsif element.is_a? SeoSlug
      element.slug
    else
      element.respond_to?(:pretty_title) ? element.pretty_title : seo_front_end_title_for_collection(element)
    end
  end
end