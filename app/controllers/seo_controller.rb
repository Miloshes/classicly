class SeoController < ApplicationController
  layout :seo_layout
  
  def show
    if @collection = Collection.book_type.where(:id => params[:id]).first rescue nil
      @books = @collection.books.page(params[:page]).per(25)
      @blessed_books = @collection.books.blessed.page(params[:page]).per(25)
      @featured_book = @collection.books.blessed.first || @collection.books.first
      render :template => 'seo/show_collection' and return
    else
      @search = params[:id]
      @books = Book.search(@search, params[:page])
      render :template => 'search/show'
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
