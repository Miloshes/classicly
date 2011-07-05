class AudiobooksController < ApplicationController
  layout 'audibly'

  def download
    @audiobook = Audiobook.find params[:id]
    @popular_books = Audiobook.blessed.random 3
    @related_book = @audiobook.find_fake_related(1).first
  end

  # Code below is when serving audiochapters, but we are now serving the whole book as a zipped file.
  # def serve_audiofile
  #     audiobook = Audiobook.find params[:id]
  #     audiochapter = AudiobookChapter.find params[:chapter_id]
  #     response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
  #     response.headers["Pragma"] = "no-cache"
  #     response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  # 
  #     send_data audiochapter.data_file,
  #         :disposition => 'attachment',
  #         :filename => "#{audiobook.pretty_title} - #{audiochapter.title}.mp3"
  #     audiobook.increment!(:downloaded_count)
  #   end
  
  def serve_audiofile
    audiobook = Audiobook.find params[:id]
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    send_data audiobook.zip_file,
              :disposition => 'attachment',
              :filename => "#{audiobook.pretty_title}.zip"
    audiobook.increment!(:downloaded_count)
  end
end
