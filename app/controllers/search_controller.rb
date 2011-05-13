class SearchController < ApplicationController
  before_filter :find_author_collections, :only => :show
  before_filter :find_genre_collections, :only => :show

  def show
    @search = params[:term]
    if params[:type] && params[:type] == 'audiobook'
      @books = Audiobook.search @search, params[:page]
      @popular_books = Audiobook.blessed.random(8)
      @audibly = true
    else
      @books = Book.search(@search, params[:page])
      @popular_books = Book.blessed.random(8)
    end
  end
  
  def autocomplete
    data = @indextank.search params[:query]
    match_count = data['matches']
    docids = data['results'].collect {|datum| datum['docid']}
    results = Search.json_for_autocomplete(docids)
    render :json => results.to_json
  end
  
  private
  def find_author_collections
    @author_collections = params[:type] == 'audiobook' ? Collection.audio_book_type.by_author : Collection.book_type.by_author
  end

  def find_genre_collections
    @genre_collections = params[:type] == 'audiobook' ? Collection.audio_book_type.by_collection : 
      Collection.book_type.by_collection
  end
end
