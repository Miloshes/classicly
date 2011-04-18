include AWS::S3

class BookPagesController < ApplicationController
  layout nil
  
  # GET /bram-stoker/dracula/page/15
  # test url: http://localhost:3000/john-galsworthy/entire-pg-galsworthy-files/read-online/page/1
  # http://localhost:3000/john-galsworthy/entire-pg-galsworthy-files/read-online/page/1?html_reader=1
  def show
    AWS::S3::Base.establish_connection!(
        :access_key_id     => APP_CONFIG['amazon']['access_key'],
        :secret_access_key => APP_CONFIG['amazon']['secret_key']
      )
    
    book        = Book.find(params[:id])
    @book_page  = book.book_pages.where(:page_number => params[:page_number]).first()
    
    if params[:html_reader]
      # == render the html reader version
      render :action => 'show', :layout => 'layouts/html_reader'
    else
      # == render the static html version
      object_name = "book_#{book.id}_page_#{params[:page_number]}.html"
      bucket_name = APP_CONFIG['buckets']['static_book_pages']

      # page has been rendered, 
      if S3Object.exists?(object_name, bucket_name) && !@book_page.force_rerender?
        render :text => S3Object.value(object_name, bucket_name)
      else
        book_page_html = render_to_string(:action => "show", :layout => 'layouts/static_book_pages')
        S3Object.store(object_name, book_page_html, bucket_name, :access => :public_read)

        @book_page.update_attributes(:force_rerender => false) if @book_page.force_rerender?

        render :text => book_page_html
      end    
    end
    
  end
  
end
