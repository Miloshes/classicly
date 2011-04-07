class SeoController < ApplicationController
  layout :seo_layout
  # before filters to show collections lists in left nav
  before_filter :find_collection
  before_filter :find_author_collections
  before_filter :find_genre_collections

  def show
    if @collection && @collection.book_type == 'book'
      @books = @collection.books.page(params[:page]).per(25)
      @blessed_books = @collection.books.blessed.page(params[:page]).per(25)
      @featured_book = @collection.books.blessed.first || @collection.books.first
      render :template => 'seo/show_collection' and return
    elsif @collection && @collection.book_type == 'audiobook'
      @audio_books = @collection.audiobooks.page(params[:page]).per(8)
      @blessed_audio_books = @collection.audiobooks.blessed.page(params[:page]).per(25)
      @featured_audio_book = @collection.audiobooks.blessed.first || @collection.audiobooks.first
      render 'audiobooks/show_audio_collection' and return
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

  def find_collection
    @collection = (Collection.book_type.where(:cached_slug => params[:id]).first  ||
        Collection.audio_book_type.where(:cached_slug => params[:id]).first) rescue nil
  end

  def find_author_collections
    if @collection && @collection.book_type == 'audiobook'
      @author_collections = Collection.audio_book_type.by_author
    else
      @author_collections = Collection.book_type.by_author
    end
  end

  def find_genre_collections
    if @collection && @collection.book_type == 'audiobook'
      @genre_collections = Collection.audio_book_type.by_collection
    else
      @genre_collections = Collection.book_type.by_collection
    end
  end

end
