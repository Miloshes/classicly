class SeoController < ApplicationController
  def show_book
    @book = Book.joins(:author).where(:cached_slug => params[:id], :author => {:cached_slug => params[:author_id]}).first  ||
        Audiobook.joins(:author).where(:cached_slug => params[:id], :author => {:cached_slug => params[:author_id]}).first
    if @book
      @books_from_the_same_collection = @book.find_more_from_same_collection(2)
      @review = session[:review] || Review.new
      session[:review] = nil
      if @book.is_a?(Book)
        render 'books/show'
      else
        render 'audiobooks/show', :layout => 'audibly'
      end
    end
  end

  def show_collection
    params[:page] = '1' if params[:page].nil?
    @seo = SeoSlug.find_by_slug(params[:id])
    if @seo && @seo.is_for_type?('collection')
      @collection = @seo.seoable
      @books = @seo.find_paginated_listed_books_for_collection(params)
      @blessed_books = @seo.find_paginated_blessed_books_for_collection(params)
      @featured_book = @seo.find_featured_book_for_collection
      @seo.seoable.is_audio_collection? ? render('show_audio_collection', :layout => 'audibly') : render('show_collection')
    else
      render_search
    end
  end
  
  def show
    @seo = SeoSlug.find_by_slug(params[:id])
    if @seo && @seo.is_valid?
      render_seo @seo
    elsif @author = Author.find(params[:id]) rescue nil
      @type = params[:type] || 'book'
      @books = Book.for_author(@author).page(params["page"]).per(8)
      render 'authors/show'
    else
      render_search
    end
  end

  private

  def render_search
    @search = params[:id]
    @books = Book.search(@search, params[:page])
    render :template => 'search/show'
  end

  def render_seo(seo)
    if seo.is_for_type?('blogpost')
      @blog_post = seo.seoable
      render 'blog/show' and return
    elsif seo.is_for_type?('collection')
      @collection = seo.seoable
      @books = seo.find_paginated_listed_books_for_collection(params)
      @blessed_books = seo.find_paginated_blessed_books_for_collection(params)
      @featured_book = seo.find_featured_book_for_collection
      if seo.seoable.is_audio_collection?
        render 'show_audio_collection', :layout => 'audibly' and return
      else
        render 'show_collection' and return
      end
    elsif seo.is_for_type?('book') || seo.is_for_type?('audiobook')
      @book = seo.seoable
      @related_books = @book.find_fake_related(8)
      @books_from_the_same_collection = @book.find_more_from_same_collection(2)
      @format = seo.download_format
      if seo.is_for_type?('audiobook')
        @audiobook = @book
        render 'audiobooks/download_special_format', :layout => 'audibly'
      elsif seo.is_for_type?('book')
        if @format == 'online'
          render 'books/read_online'
        else
          render 'books/download_special_format'
        end
      end
    end
  end
end
