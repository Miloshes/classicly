module ApplicationHelper
  def list_element_link(collection)
    content_tag :li do
      link_to collection.name, seo_path(collection)
    end
  end

  def typekit_include_helper
    javascript_include_tag('http://use.typekit.com/idk3svd.js').concat(javascript_tag "try{ Typekit.load();}catch(e){}")
  end
  
  def fb_open_graph_metadata(config = {})
    content_tag(:meta, nil, {:property => "og:title", :content => config[:title] || "Classicly"}) +
    content_tag(:meta, nil, {:property => "og:type", :content => config[:type] || "website"}) +
    content_tag(:meta, nil, {:property => "og:url", :content => config[:url] || "http://www.classicly.com"}) +
    content_tag(:meta, nil, {:property => "og:image", :content => config[:image] || "http://www.classicly.com/images/logo.png"}) +
    content_tag(:meta, nil, {:property => "og:site_name", :content => "Classicly"}) +
    content_tag(:meta, nil, {:property => "fb:app_id", :content => "191005167590330"}) +
    content_tag(:meta, nil, {:property => "og:description", :content => config[:description] || "Classicly gives you free books for your laptop,  Kindle, Nook, iPad, or iPhone. Just hit download! From Shakespeare to F. Scott Fitzgerald we have all the classics available with a click, browsable with beautiful covers, great descriptions, and hand-picked collections"})
  end

  def radio_button_for_format(format, index, featured_book)
    checked = (index == 0)
    radio_button_tag("download_format", format, checked, :id => "radio%s_%s" % [index, featured_book.id]) + label_tag("radio%s_%s" % [index, featured_book.id], format == 'azw' ? 'Kindle' : format.upcase)
  end

  def search(path)
    form_tag path do
      content_tag(:div, nil, :id => 'search-bg') do
        text_field_tag 'Search'
      end
    end
  end

  def parsed_collection_description(description)
    doc = Nokogiri::HTML(description)
    books = doc.xpath("//book") # get all <book> tags
    books.each do |book|
      book_id = book.attributes["id"].value
      book.name = "a"
      book.set_attribute("href", seo_path(book_id))
    end
    doc.css('body').inner_html
  end

end
