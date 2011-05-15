class BooksController < ApplicationController
  before_filter :find_author_collections, :only => [:show, :download, :kindle_format, :pdf_format]
  before_filter :find_genre_collections, :only => [:show, :download, :kindle_format, :pdf_format]

  before_filter :find_book, :only => [:download, :serve_downloadable_file, :show_review_form]
  before_filter :find_book_with_specific_author, :only => [:show, :kindle_format, :pdf_format]
  before_filter :find_format, :only => [:download, :serve_downloadable_file]

  def ajax_paginate
    @collection = Collection.find(params[:id])
    @books = if params[:sort_by].nil?
      @collection.books.page(params[:page]).per(25)
    else
      params[:sort_by] == 'author' ? @collection.books.order_by_author.page(params[:page]).per(25) : 
        @collection.books.order(params[:sort_by]).page(params[:page]).per(25)
    end
    render :layout => false
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
    @book.on_download(current_login.try(:fb_connect_id), @mixpanel)
  end

  def show
    @related_books = @book.find_fake_related(8)
    @books_from_the_same_collection = @book.find_more_from_same_collection(2)
    @book.on_each_view(current_login.try(:fb_connect_id), @mixpanel) if Rails.env.production?
    # if there was a failed review, it will come in the session object
    @review = session[:review] || Review.new
    session[:review] = nil
    layout 'new_design'
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
