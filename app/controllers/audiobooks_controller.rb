class AudiobooksController < ApplicationController
  before_filter :find_audio_author_collections
  before_filter :find_audio_genre_collections
  before_filter :find_audio_book_with_author, :only => :show

  def index
    @related_books = Audiobook.blessed.random(8)
    @featured_audiobooks = Audiobook.blessed.random(5)
  end

  def show
    @related_audio_books = @audio_book.find_fake_related(8)
    @audio_books_from_the_same_collection = @audio_book.find_more_from_same_collection(2)
  end

  def seo
    if @collection = Collection.type_audiobook.where(:cached_slug => params[:id]).first rescue nil
      @audiobooks = @collection.audiobooks.page(params[:page]).per(8)
      @blessed_audiobooks = @collection.audiobooks.blessed.page(params[:page]).per(25)
      @featured_audiobook = @collection.audiobooks.blessed.first || @collection.audiobooks.first
      render :show_audio_collection and return
    else
      redirect_to search_path
    end
  end

  def ajax_paginate
    @audiobooks = Collection.find(params[:id]).audiobooks.page(params[:page]).per(8)
    render :layout => false
  end

  private
  def find_audio_author_collections
    @audio_author_collections = Collection.type_audiobook.by_author
  end

  def find_audio_genre_collections
    @audio_genre_collections = Collection.type_audiobook.by_collection
  end

  def find_audio_book_with_author
    @audio_book = Audiobook.joins(:author).where(:cached_slug => params[:id], :author => {:cached_slug => params[:author_id]}).first
  end
end
