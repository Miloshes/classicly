class BooksController < ApplicationController
  before_filter :find_author_collections, :only => [:show, :download]
  before_filter :find_genre_collections, :only => [:show, :download]

  before_filter :find_book, :only => [:download, :serve_downloadable_file, :show_review_form]
  before_filter :find_book_with_specific_author, :only => :show
  before_filter :find_format, :only => [:download, :serve_downloadable_file]

  def show
    @related_books = @book.find_fake_related(8)
    @books_from_the_same_collection = @book.find_more_from_same_collection(2)
    mixpanel_properties = {:title => @book.pretty_title}
    if user_signed_in?
      mixpanel_properties.merge!({:id => current_login.fb_connect_id})
    end
    @mixpanel.track_event("Viewed Book", mixpanel_properties) if Rails.env.production?
    # if there was a failed review, it will come in the session object
    @review = session[:review] || Review.new
    session[:review] = nil
  end

  # for invoking the download page
  def download
    @related_books = @book.find_fake_related(8)
  end
  
  # for actually serving the downloadable file
  def serve_downloadable_file
    # The Library app tries to request PDF for book devliveries, whether we have it or not
    # Falling back to RTF if we don't have it
    if @format == 'pdf' && !@book.available_in_format?(@format)
      @format = 'rtf'
    end
    
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    send_data(
        @book.file_data_for_format(@format),
        :disposition => 'attachment',
        :filename => "#{@book.pretty_title}.#{@format}"
      )
    Book.update_counters @book.id, :downloaded_count => 1
    mixpanel_properties = {:book => @book.pretty_title}
    if user_signed_in?
      mixpanel_properties.merge!({:id => current_login.fb_connect_id})
    end
    @mixpanel.track_event("Download Book", mixpanel_properties) if Rails.env.production?
  end

  def ajax_paginate
    @books = Collection.find(params[:id]).books.page(params[:page]).per(25)
    render :layout => false
  end

  def show_review_form
    @review = Review.new
    render :layout => false
  end

  private 

  def find_book_with_specific_author
    @book = Book.joins(:author).where(:cached_slug => params[:id], :author => {:cached_slug => params[:author_id]}).first
  end

  def find_book
    @book = Book.find(params[:id])
  end

  def find_format
    @format = params[:download_format]
  end

end
