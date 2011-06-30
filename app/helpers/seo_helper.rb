module SeoHelper # Please don't put into application helper
  
  def download_format_page_title(book, format)
    format = (format == 'azw') ? 'Kindle' : format.upcase
    # 70 chars is the limit, but substract  4 characters for ' by '
    prefix = 'Download'
    if [prefix, book.pretty_title, format].map(&:length).reduce(:+) <= 70
      "#{prefix} #{book.pretty_title} #{format}"
    else
      "#{prefix} #{shorten_title(book.pretty_title, 70 - prefix.length - format.length)}#{format}"
    end
  end
  
  def fb_open_graph_metadata(config={}, seo_info = nil)
    content_tag(:meta, nil, {:property => "og:title", :content => seo_info.try(:og_title) || config[:title] || "Classicly"}) +
    content_tag(:meta, nil, {:property => "og:type", :content => config[:type] || "website"}) +
    content_tag(:meta, nil, {:property => "og:url", :content => config[:url] || "http://www.classicly.com"}) +
    content_tag(:meta, nil, {:property => "og:image", :content => config[:image] || "http://www.classicly.com/images/logo.png"}) +
    content_tag(:meta, nil, {:property => "og:site_name", :content => "Classicly"}) +
    content_tag(:meta, nil, {:property => "fb:app_id", :content => Facebook::APP_ID}) +
    content_tag(:meta, nil, {:property => "og:description", :content => seo_info.try(:og_description) || config[:description] || "23,469 of the world's greatest free books, available for free in PDF,  Kindle, Sony Reader, iBooks, and more. You can also read online!"})
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
    element.seo_info ? element.seo_info.metadescription : SeoDefault.parse_default_value(:metadescription, element)
  end
  
  # an infoable can be seo slug, collection, book , or audiobook
  def seo_front_end_title_helper(element)
    element.seo_info ? element.seo_info.title : SeoDefault.parse_default_value(:webtitle, element)
  end
  
  def title_for_special_landing_page(seo_slug)
    seo_slug.seo_info ? seo_slug.seo_info.title : SeoDefault.parse_default_value(:webtitle, seo_slug)
  end
end