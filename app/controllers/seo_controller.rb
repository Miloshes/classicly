class SeoController < ApplicationController
  # before filters to show collections lists in left nav
  before_filter :find_collection
  before_filter :find_book_or_audio_book, :only => :book
  before_filter :find_author_collections
  before_filter :find_genre_collections
  layout :seo_layout

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

  def book
    if @book
      @related_books = @book.find_fake_related(8)
      @books_from_the_same_collection = @book.find_more_from_same_collection(2)
      mix_panel_properties = {:title => @book.pretty_title}
      if user_signed_in?
        mix_panel_properties.merge!({:id => current_login.fb_connect_id})
      end
      @mixpanel.track_event("Viewed Book", mix_panel_properties) if Rails.env.production?
      # if there was a failed review, it will come in the session object
      @review = session[:review] || Review.new
      session[:review] = nil
      render 'books/show'
    elsif @audio_book
      @related_audio_books = @audio_book.find_fake_related(8)
      @audio_books_from_the_same_collection = @audio_book.find_more_from_same_collection(2)
      render 'audiobooks/show'
    end
  end

  private

  def seo_layout
    @collection ? 'collections': 'application'
  end

  def find_collection
    @collection = (Collection.book_type.where(:cached_slug => params[:id]).first  ||
        Collection.audio_book_type.where(:cached_slug => params[:id]).first) rescue nil
  end

  def find_author_collections
    if (@collection && @collection.book_type == 'audiobook') || @audio_book
      @author_collections = Collection.audio_book_type.by_author
    else
      @author_collections = Collection.book_type.by_author
    end
  end

  def find_genre_collections
    if (@collection && @collection.book_type == 'audiobook') || @audio_book
      @genre_collections = Collection.audio_book_type.by_collection
    else
      @genre_collections = Collection.book_type.by_collection
    end
  end


  def find_book_or_audio_book
    @book = Book.joins(:author).where(:cached_slug => params[:id], :author => {:cached_slug => params[:author_id]}).first rescue nil
    unless @book
      @audio_book = Audiobook.joins(:author).where(:cached_slug => params[:id], :author => {:cached_slug => params[:author_id]}).first rescue nil
    end
  end
end
