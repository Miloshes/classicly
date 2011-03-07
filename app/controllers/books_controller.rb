class BooksController < ApplicationController
  before_filter :find_book
  before_filter :find_format

  def download
  end

  private 

  def find_book
    @book = Book.find(params[:id])
  end

  def find_format
    @format = params[:download_format]
  end

end
