class BooksController < ApplicationController
  before_filter :find_book
  before_filter :find_related, :only => :show
  before_filter :find_format, :only => :download
  def show
  end

  def download
  end

  private 

  def find_book
    @book = Book.find_by_id(params[:id])
  end

  def find_format
    @format = params[:download_format]
  end

  def find_related
    @related = @book.find_fake_related(2)
  end
end
