class BooksController < ApplicationController
  before_filter :find_book, :only => [:download, :serve_downloadable_file, :show_review_form]
  before_filter :find_book_with_specific_author, :only => [:show, :kindle_format, :pdf_format]
  before_filter :find_format, :only => [:download, :serve_downloadable_file]


  # for invoking the download page
  def download
    @popular_books = Book.blessed.random 3
    @related_book = @book.find_fake_related(1).first
  end

  def download_and_add_to_library
    session[:new_book_in_library] = params[:book_id]
    session[:download_format_for_the_new_book] = params[:download_format]

    redirect_to library_url
  end

  # for actually serving the downloadable file
  def serve_downloadable_file
    @format = 'azw' if @format == 'kindle'
    
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

  def show
    @related_books = @book.find_fake_related(3)
    # if there was a failed review, it will come in the session object
    @review = session[:review] || Review.new
    session[:review] = nil
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
