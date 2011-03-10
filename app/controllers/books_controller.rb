class BooksController < ApplicationController
  before_filter :find_book
  before_filter :find_format

  def show
    @related_books = @book.find_fake_related(8)
    @books_from_the_same_collection = @book.find_more_from_same_collection(2)
  end

  # for invoking the download page
  def download
    @related_books = @book.find_fake_related(8)
  end
  
  # for actually serving the downloadable file
  def serve_downloadable_file
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    send_data(
        @book.file_data_for_format(@format),
        :disposition => 'attachment',
        :filename => "#{@book.title}.#{@format}"
      )
  end

  def ajax_paginate
    @blessed_books = Book.blessed.page(params[:page]).per(25)
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
