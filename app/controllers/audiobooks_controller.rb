class AudiobooksController < ApplicationController
  before_filter :find_audio_author_collections
  before_filter :find_audio_genre_collections
  def index
    @related_books = Audiobook.blessed.random(8)
    @featured_audio_books = Audiobook.blessed.random(5)
  end

  def ajax_paginate
    @audio_books = Collection.find(params[:id]).audiobooks.page(params[:page]).per(8)
    render :layout => false
  end

  private
  def find_audio_author_collections
    @audio_author_collections = Collection.audio_book_type.by_author
  end

  def find_audio_genre_collections
    @audio_genre_collections = Collection.audio_book_type.by_collection
  end
end
