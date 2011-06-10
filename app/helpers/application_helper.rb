module ApplicationHelper

  def book_author_link(book, klass='')
    if book.author.has_collection?
      link_to book.author.name, seo_path(book.author.collection.cached_slug), :class => klass
    else
      link_to book.author.name, seo_path(book.author), :class => klass
    end
  end

  def audiobook_author_link(book, klass='')
    if book.author.has_audio_collection? 
      link_to book.author.name, seo_path(book.author.audio_collection.cached_slug), :class => klass
    else
     link_to book.author.name, seo_path(book.author, :type => 'audiobook'), :class => klass
    end
  end
  
  def author_featured_book_image_link(author, type, html_class=nil)
    book = author.featured_book(type)
    bucket = "#{type}_id"
    link_to image_tag("http://spreadsong-#{type}-covers.s3.amazonaws.com/#{bucket}#{book.id}_size3.jpg",
                      :alt => "#{book.pretty_title} by #{author.name}", :class => html_class),
                      author_book_url(author,book)
  end
  
  def cover_image_link(cover, size, html_class=nil)
    type = cover.class.to_s.downcase
    bucket = "#{type}_id"
    link_to image_tag("http://spreadsong-#{type}-covers.s3.amazonaws.com/#{bucket}#{cover.id}_size#{size}.jpg",
                      :alt => "#{cover.pretty_title} by #{cover.author.name}", :class => html_class),
                      author_book_url(cover.author, cover)
  end

  def cover_tag(book, size='2', klass='')
    type = book.class.to_s.downcase
    image_tag "http://spreadsong-#{type}-covers.s3.amazonaws.com/#{type}_id#{book.id}_size#{size}.jpg", :class => klass
  end
  
  def image_or_link_to_download_format(book, format)
    image = (format == 'azw') ? 'download_kindle.png' : 'download_pdf.png' 
    if book.available_in_format?(format)
      link_to image_tag(image), download_book_url(book.author, book, :download_format => format)
    else
      image_tag image
    end
  end

  def link_cover_tag(book, size='2', klass='')
    type = book.class.to_s.downcase
    link_to image_tag("http://spreadsong-#{type}-covers.s3.amazonaws.com/#{type}_id#{book.id}_size#{size}.jpg",
                      :class => klass, :alt => book.pretty_title ), author_book_url(book.author, book)
  end
  
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

  def radio_button_for_format(format, index, featured_book)
    checked = (index == 0)
    radio_button_tag("download_format", format, checked, :id => "radio%s_%s" % [index, featured_book.id]) + label_tag("radio%s_%s" % [index, featured_book.id], format == 'azw' ? 'Kindle' : format.upcase)
  end

  # replaces <book> tag for a new html tag:
  def remove_book_tags(text, html_tag)
    doc = Nokogiri::HTML( text )
    doc.xpath("//book").each {|book| book.name = html_tag}
    doc.xpath('//quote').each {|quote| quote.remove }
    doc.css('body').inner_html
  end

  def limit_to_paragraph(text)
    doc = Nokogiri::HTML(text)
    doc.xpath("//p").first.inner_html
  end

  def links_for_downloading_special_formats(book)
    res = "Download As"
    already_one_found = false
    ['azw', 'pdf'].each_with_index do|format, index|
      if book.available_in_format?(format)
        res << ' or' if index > 0 && already_one_found
        tag = format == 'azw' ? 'Kindle' : format.upcase
        res << " #{ link_to tag, book.url_for_specific_format(format)}"
        already_one_found = true
      end
    end
    res
  end

  def search_form(path, search_term)
    form_tag path, :method => :get do
      content_tag(:div, nil, :class => 'search-bg') do
        text_field_tag "term", search_term
      end
    end
  end
  
  def sort_audiobooks_ajax_link(id, text, sort_by)
    link_to text, { :controller => 'audiobooks', :action => 'ajax_paginate', :id => id, :sort_by => sort_by},
      :class => 'selected', :name => "sort_by_#{sort_by}",  :remote => true
  end

  def sort_books_ajax_link(id, text, sort_by)
    link_to text, { :controller => 'books', :action => 'ajax_paginate', :id => id, :sort_by => sort_by},
      :class => 'selected', :name => "sort_by_#{sort_by}",  :remote => true
  end
  def shorten_text(text, limit)
    return text if text.length <= limit
    text.slice(0, (limit - 3)).concat("...")
  end

  def facebook_image(fb_connect_id)
    image_tag "http://graph.facebook.com/%s/picture?type=square" % fb_connect_id
  end
#===========================================================================================================================
#===========================================================================================================================
# books only helpers

def condensed_blog_post_content(post)
  content = post.content
  return '' if post.content.nil?
  boundary = content.length > 800 ? 800 : content.length
  content[0, boundary]
end

def condensed_description(book)
  return '' if book.description.nil?
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

def shorten_title(limit)
  return self.pretty_title if self.pretty_title.length <= limit
  self.pretty_title.slice(0, (limit - 3)).concat("...")
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

def render_listed_book_partial(books)
  if books.first.class == Book
    render :partial => '/books/listed_book', :collection => @books, :as => :book
  else
    render :partial => '/audiobooks/listed_audio_book', :collection => @books, :as => :audio_book
  end
end
