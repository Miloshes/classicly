class AudiobooksController < ApplicationController
  before_filter :find_audio_author_collections
  before_filter :find_audio_genre_collections
  layout 'application'

  def index
    @related_books = Audiobook.blessed.random(8)
    @featured_audio_books = Audiobook.blessed.random(5)
    @audibly = true
  end

  def ajax_paginate
    @collection = Collection.find(params[:id])
    @audio_books = @collection.ajax_paginated_audiobooks params
    render :layout => false
  end

  private
  def find_audio_author_collections
    @author_collections = Collection.audio_book_type.by_author
  end

  def find_audio_genre_collections
    @genre_collections = Collection.audio_book_type.by_collection
  end
end
