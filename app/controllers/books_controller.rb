class BooksController < ApplicationController
  before_filter :find_book
  before_filter :find_format

  def show
    @related_books = @book.find_fake_related(8)
    @books_from_the_same_collection = @book.find_more_from_same_collection(2)
  end

  def download
    @related_books = @book.find_fake_related(8)
  end

  private 

  def find_book
    @book = Book.find(params[:id])
  end

  def find_format
    @format = params[:download_format]
  end

end
