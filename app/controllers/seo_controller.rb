class SeoController < ApplicationController
  layout :seo_layout
  
  def show
    if @collection = Collection.find(params[:id]) rescue nil
      @books = @collection.books.page(params[:page]).per(25)
      @blessed_books = @collection.books.blessed.page(params[:page]).per(25)
      @featured_book = @collection.books.blessed.first || @collection.books.first
      render :template => 'seo/show_collection' and return
    elsif @book = Book.find(params[:id]) rescue nil
      @related_books = @book.find_fake_related(8)
      @books_from_the_same_collection = @book.find_more_from_same_collection(2)
      @review = Review.new
      render :template => 'seo/show_book' and return
    else
      @search = params[:id]
      @books = Book.joins(:collections).joins(:author).where(
      {:title.matches => "%#{@search}%"} | 
      {:collections => {:name.matches => "%#{@search}%"}} |
      {:author => {:name.matches => "%#{@search}%"}}).page(params[:page]).per(10)
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
