class AudiobooksController < ApplicationController
  layout 'audibly'

  def ajax_paginate
    @collection = Collection.find params[:id]
    @audiobooks = @collection.ajax_paginated_audiobooks params
    render :layout => false
  end

  def index
    @related_books = Audiobook.blessed.random(8)
    @featured_audio_books = Audiobook.blessed.random(5)
    @audibly = true
  end
  
  def json_audiobooks
    data = []
    book_ids = params[:id].split( ',' )
    book_ids.each do |id|
      # find the book:
      current = Audiobook.where(:id => id).select('id, cached_slug, author_id').first
      # create the books data to be converted in json:
      author_slug = Author.where(:id => current.author_id).select('cached_slug').first.cached_slug
      attrs = current.attributes.merge(:author_slug => author_slug)
      # add the book id to the data to be sent:
      data << {:attrs => attrs} 
    end
    render :json => data.to_json
  end

  def random_json
    audiobooks = Audiobook.blessed.no_squat_image.select('audiobooks.id, author_id, cached_slug, pretty_title').random(params[:total_audiobooks].to_i)
    render :json => Audiobook.hashes_for_JSON(audiobooks)
  end
  
  def related_audiobooks_in_json
    audiobooks = [ ]
    audiobook = Audiobook.find params[:id]
    audiobooks << audiobook
    audiobooks += audiobook.find_fake_related(params[:total_related].to_i,  ['audiobooks.id', 'author_id', 'cached_slug', 'pretty_title'])
    render :json => Audiobook.hashes_for_JSON(audiobooks)
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
    audiobook.increment!(:downloaded_count)
  end
end
