class BooksController < ApplicationController
  before_filter :find_book
  before_filter :find_format

  def show
    @related_books = @book.find_fake_related(8)
    @books_from_the_same_collection = @book.find_more_from_same_collection(2)
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
  end

  def ajax_paginate
    @books = Collection.find(params[:id]).books.page(params[:page]).per(25)
    render :layout => false
  end

  def show_review_form
    @book = Book.find_by_id(params[:id])
    @review = Review.new
    render :layout => false
  end

  private 

  def find_book
    @book = Book.find(params[:id])
  end

  def find_format
    @format = params[:download_format]
  end

end
