class SeoController < ApplicationController
  before_filter :find_book_or_audio_book, :only => :show_book
  before_filter :find_author_collections
  before_filter :find_genre_collections
  layout :seo_layout

  def show_book
    if @book
      @related_books = @book.find_fake_related(8)
      @books_from_the_same_collection = @book.find_more_from_same_collection(2)
      @book.log_book_view_in_mix_panel(current_login.try(:fb_connect_id), @mixpanel)
      @audibly = @book.class == Audiobook
      @review = session[:review] || Review.new
      session[:review] = nil
      render @book.class == Book ? 'books/show' : 'audiobooks/show'
    end
  end

  def show
    seo = SeoSlug.find_by_slug(params[:id])
    if seo && seo.is_valid?
      render_seo seo
    else
      render_search
      @audibly = false
    end
  end

  private
  def find_author_collections
    if (@collection && @collection.book_type == 'audiobook') || @book.class == Audiobook
      @author_collections = Collection.audio_book_type.by_author
    else
      @author_collections = Collection.book_type.by_author
    end
  end

  def find_genre_collections
    if (@collection && @collection.book_type == 'audiobook') || @book.class == Audiobook
      @genre_collections = Collection.audio_book_type.by_collection
    else
      @genre_collections = Collection.book_type.by_collection
    end
  end


  def find_book_or_audio_book
    @book = Book.joins(:author).where(:cached_slug => params[:id], :author => {:cached_slug => params[:author_id]}).first  ||
        Audiobook.joins(:author).where(:cached_slug => params[:id], :author => {:cached_slug => params[:author_id]}).first
  end

  def render_search
    @search = params[:id]
    @books = Book.search(@search, params[:page])
    render :template => 'search/show'
  end

  def render_seo(seo)
    @audibly = false
    if seo.is_for_collection?
      @collection = seo.seoable
      @books = seo.find_paginated_listed_books_for_collection(params)
      @blessed_books = seo.find_paginated_blessed_books_for_collection(params)
      @featured_book = seo.find_featured_book_for_collection
      if seo.seoable.is_audio_collection?
        @audibly = true
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
    @review = session[:review] || Review.new
    session[:review] = nil
    @format = seo.download_format
    if seo.is_for_audio_book?
      @audibly = true
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
end
