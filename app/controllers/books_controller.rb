class BooksController < ApplicationController
  before_filter :find_book
  before_filter :find_related
  def show
  end

  private 

  def find_book
    @book = Book.find_by_id(params[:id])
  end

  def find_related
    @related = Book.all(:limit => 2)
  end
end
