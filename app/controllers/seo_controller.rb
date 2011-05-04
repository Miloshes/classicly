class SeoController < ApplicationController
  before_filter :find_book_or_audio_book, :only => :show_book
  layout :seo_layout

  def show_book
    if @book
      @related_books = @book.find_fake_related(8)
      @books_from_the_same_collection = @book.find_more_from_same_collection(2)
      @book.log_book_view_in_mix_panel(current_login.try(:fb_connect_id), @mixpanel)
      set_collections_and_audibly_for_book(@book)
      @review = session[:review] || Review.new
      session[:review] = nil
      render @book.class == Book ? 'books/show' : 'audiobooks/show'
    end
  end

  def show
    @seo = SeoSlug.find_by_slug(params[:id])
    if @seo && @seo.is_valid?
      render_seo @seo
    elsif @author = Author.find(params[:id]) rescue nil
      @type = params[:type] || 'book'
      @genre_collections = find_genre_collections @type.to_sym
      @author_collections = find_author_collections @type.to_sym
      @audibly = (@type == 'audiobook')
      render 'authors/show'
    else
      render_search
      @audibly = false
    end
  end

  private
  def find_author_collections(type)
    return  Collection.audio_book_type.by_author if type == :audiobook
    Collection.book_type.by_author
  end

  def find_genre_collections(type)
    return  Collection.audio_book_type.by_collection if type == :audiobook
    Collection.book_type.by_collection
  end


  def find_book_or_audio_book
    @book = Book.joins(:author).where(:cached_slug => params[:id], :author => {:cached_slug => params[:author_id]}).first  ||
        Audiobook.joins(:author).where(:cached_slug => params[:id], :author => {:cached_slug => params[:author_id]}).first
  end

  def render_search
    @search = params[:id]
    @books = Book.search(@search, params[:page])
    @genre_collections = find_genre_collections :book
    @author_collections = find_author_collections :book
    @popular_books = Book.blessed.random(8)
    render :template => 'search/show'
  end

  def render_seo(seo)
    if seo.is_for_collection?
      @collection = seo.seoable
      @books = seo.find_paginated_listed_books_for_collection(params)
      @blessed_books = seo.find_paginated_blessed_books_for_collection(params)
      @featured_book = seo.find_featured_book_for_collection
      set_collections_and_audibly_for_collection(seo.seoable)
      if seo.seoable.is_audio_collection?
        render 'show_audio_collection' and return
      else
        render 'show_collection' and return
      end
    end
    # gets here if seo is for a book
    @book = seo.seoable
    @related_books = @book.find_fake_related(8)
    @books_from_the_same_collection = @book.find_more_from_same_collection(2)
    @book.log_book_view_in_mix_panel(current_login.try(:fb_connect_id), @mixpanel)
    set_collections_and_audibly_for_book(@book)
    @review = session[:review] || Review.new
    session[:review] = nil
    @format = seo.download_format
    if seo.is_for_audio_book?
      render 'audiobooks/download'
    elsif seo.is_for_book?
      if @format == 'online'
        render 'books/read_online'
      else
        render 'books/download_special_format'
      end
    end
  end

  def seo_layout
    @collection ? 'collections': 'application'
  end

  def set_collections_and_audibly_for_book(book)
    book_type = book.class.to_s.downcase.to_sym
    @genre_collections = find_genre_collections book_type
    @author_collections = find_author_collections book_type
    @audibly = book_type == :audiobook
  end

  def set_collections_and_audibly_for_collection(collection)
    collection_type = collection.is_audio_collection? ? :audiobook : :book
    @genre_collections = find_genre_collections collection_type
    @author_collections = find_author_collections collection_type
    @audibly = collection_type == :audiobook
  end
end
