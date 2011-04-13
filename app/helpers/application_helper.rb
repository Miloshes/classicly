module ApplicationHelper

  def current_login
    Login.where(:fb_connect_id => @profile_id).first
  end

  def user_signed_in?
    @profile_id != nil && Login.exists?(:fb_connect_id => @profile_id)
  end

  def list_element_link(collection)
    content_tag :li do
      link_to(collection.name, seo_url(collection))
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
    content_tag(:meta, nil, {:property => "fb:app_id", :content => Facebook::APP_ID}) +
    content_tag(:meta, nil, {:property => "og:description", :content => config[:description] || "23,469 of the world’s greatest free books, available for free in PDF,  Kindle, Sony Reader, iBooks, and more. You can also read online!"})
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
      book.set_attribute("href", author_book_url(book_object.author, book_object))
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
  
  def facebook_image(fb_connect_id)
    image_tag "http://graph.facebook.com/%s/picture?type=square" % fb_connect_id
  end
#===========================================================================================================================
#===========================================================================================================================
# books only helpers

def condensed_description(book)
  #get the first paragraph or the hole description if no paragraphs present
  paragraph_boundary = (book.description =~ /\n/) || book.description.length
  single_paragraph = paragraph_boundary <= 350
  paragraph_boundary = 350 unless single_paragraph
  # get the string that is left from chopping the first paragraph
  chars_left = book.description.length - paragraph_boundary
  trailing_string = book.description[paragraph_boundary, chars_left]
  paragraph_boundary += trailing_string.index(' ') unless single_paragraph # either we have a complete paragraph or a paragraph choopped but with no broken words ( we get the last blankspace)
  simple_format book.description[0, paragraph_boundary] + '...' +  link_to('  more', author_book_url(book.author, book))
end
def special_format_download_book_link(format)
  content_tag(:span, @format == 'azw' ? "Click to download for Kindle" : "Click to download as #{format.upcase}")
end
#==========================================================================================================================
#stars helper
 def ratings_input_for_book(book)
   html = ""
   1.upto(5) do|rating|
    html += book.radio_button('rating', rating, :class => 'star')
   end
   html
 end
 
 def show_review_rating_stars(rating)
   stars_on = rating || 1
   stars_off = 5 - stars_on
   html = ''
   1.upto(stars_on) do
     html += content_tag(:div, nil ,:class => 'star-on')
   end
   if stars_off > 0
     1.upto(stars_off) do
       html += content_tag(:div, nil, :class => 'star-off')
     end
   end
   html
 end
#==========================================================================================================================
#helpers for analytics
  def render_performable_script(type)
    case type
    when :author
      "<script type='text/javascript'>var _paq = _paq || [];_paq.push(['trackConversion', {id: '7dVnMY92mgit',
      value: null}]);</script>"
    else
      "<script type='text/javascript'>var _paq = _paq || [];_paq.push(['trackConversion', {id: '3D5BM25rvvhv',
      value: null}]);</script>"
    end
  end
end
