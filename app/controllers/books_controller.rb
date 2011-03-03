class BooksController < ApplicationController
  before_filter :find_book
  before_filter :find_related, :only => :show
  def show
  end

  def download
    #redirect_to @book.download_url_for_format(params[:download_format])
  end

  private 

  def find_book
    @book = Book.find_by_id(params[:id])
  end

  def find_related
    @related = Book.all(:limit => 2)
  end
end
