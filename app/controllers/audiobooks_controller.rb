class AudiobooksController < ApplicationController
  before_filter :find_audio_author_collections
  before_filter :find_audio_genre_collections
  layout 'application'

  def ajax_paginate
    @collection = Collection.find(params[:id])
    @audio_books = @collection.ajax_paginated_audiobooks params
    render :layout => false
  end

  def index
    @related_books = Audiobook.blessed.random(8)
    @featured_audio_books = Audiobook.blessed.random(5)
    @audibly = true
  end

  def serve_audiofile
    audiobook = Audiobook.find params[:id]
    audiochapter = AudiobookChapter.find params[:chapter_id]
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"

    send_data audiochapter.data_file,
        :disposition => 'attachment',
        :filename => "#{audiobook.pretty_title} - #{audiochapter.title}.mp3"
  end

  private
  def find_audio_author_collections
    @author_collections = Collection.audio_book_type.by_author
  end

  def find_audio_genre_collections
    @genre_collections = Collection.audio_book_type.by_collection
  end
end
