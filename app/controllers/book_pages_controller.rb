class BookPagesController < ApplicationController

  # GET /bram-stoker/dracula/page/15
  # test url: http://localhost:3000/read-dracula-online-free/page/1
  def show
    slug = SeoSlug.where(:slug => params[:id]).first
    book = slug.seoable

    # render the book if it's necessary
    if !book.is_rendered_for_online_reading?
      book.render_book_for_online_reading!
    end

    @book_page = book.book_pages.where(:page_number => params[:page_number]).first()

    # if we have a user logged in, set this book's last-opened property in his library
    if current_login
      library_book = current_library.library_books.find_or_create_by_library_id_and_book_id(current_library.id, book.id)
      @bookmarked = library_book.is_bookmarked_at? @book_page.page_number # flag used for UI reasons.
      library_book.update_attributes(:last_opened => Time.now)
    end

    # set the book's global_last_opened to now
    book.update_attributes(:global_last_opened => Time.now)

    if @book_page.nil?
      redirect_to author_book_path(book.author, book)
    else
      # render the html reader version:
      render :action => 'show', :layout => 'layouts/html_reader'
    end

    # if params[:html_reader]
    # else
    #   # == render the static html version
    #   object_name = "book_#{book.id}_page_#{params[:page_number]}.html"
    #   bucket_name = APP_CONFIG['buckets']['static_book_pages']
    # 
    #   # page has been rendered, 
    #   if S3Object.exists?(object_name, bucket_name) && !@book_page.force_rerender?
    #     render :text => S3Object.value(object_name, bucket_name)
    #   else
    #     book_page_html = render_to_string(:action => "show", :layout => 'layouts/static_book_pages')
    #     S3Object.store(object_name, book_page_html, bucket_name, :access => :public_read)
    # 
    #     @book_page.update_attributes(:force_rerender => false) if @book_page.force_rerender?
    # 
    #     render :text => book_page_html
    #   end
    # end
  end

  #todo authenticate before doing this
  def render_book
    unless params[:book_id]
      render :text => "400: missing 'id' in request params.", :status => 400
      return
    end
    @book_id = params[:book_id]
    render :action => 'render', :layout => 'layouts/render'    
  end
  
end
