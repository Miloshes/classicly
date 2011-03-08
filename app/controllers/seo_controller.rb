class SeoController < ApplicationController
  layout :seo_layout
  
  def show
    if @collection = Collection.find(params[:id]) rescue nil
      @blessed_books = Book.blessed.page(params[:page]).per(25)
      @featured_book = @collection.books.first
      render :template => 'seo/show_collection' and return
    elsif @book = Book.find(params[:id])
      @related_books = @book.find_fake_related(8)
      @books_from_the_same_collection = @book.find_more_from_same_collection(2)
      render :template => 'seo/show_book' and return
    end
  end
  
  private

  def seo_layout
    if @collection = Collection.find(params[:id]) rescue nil
      'collections'
    else
      'application'
    end
  end
end
