class AudiobooksController < ApplicationController
  before_filter :find_audio_author_collections
  before_filter :find_audio_genre_collections
  def index
    @related_books = Audiobook.blessed.random(8)
    @featured_audiobooks = Audiobook.blessed.random(5)
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
end
