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
    content_tag(:meta, nil, {:property => "og:description", :content => config[:description] || "24,469 of the world’s greatest free books, available for free in PDF,  Kindle, Sony Reader, iBooks, and more. You can also read online!"})
  end

  def radio_button_for_format(format, index, featured_book)
    checked = (index == 0)
    radio_button_tag("download_format", format, checked, :id => "radio%s_%s" % [index, featured_book.id]) + label_tag("radio%s_%s" % [index, featured_book.id], format == 'azw' ? 'Kindle' : format.upcase)
  end


  def parsed_collection_description(description)
    doc = Nokogiri::HTML(description)
    books = doc.xpath("//book") # get all <book> tags
    books.each do |book|
      book_id = book.attributes["id"].value
      book_object = Book.find(book_id)
      book.name = "a"
      book.set_attribute("href", author_book_path(book_object.author, book_object))
      book.set_attribute("class", "description-link")
    end
    quotes = doc.xpath('//quote')
    quotes.each do|quote|
      quote.remove
    end
    doc.css('body').inner_html
  end
  
  def limit_to_paragraph(text)
    doc = Nokogiri::HTML(text)
    doc.xpath("//p").first.inner_html
  end

  def search_form(path, search_term)
    form_tag path, :method => :get do
      content_tag(:div, nil, :class => 'search-bg') do
        text_field_tag "term", search_term
      end
    end
  end
#===========================================================================================================================
#===========================================================================================================================
# books only helpers
end
