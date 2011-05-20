class SearchController < ApplicationController
  before_filter :find_author_collections, :only => :show
  before_filter :find_genre_collections, :only => :show

  def show
    @search = params[:term]
    documents = @indextank.search "#{@search} type:book"
    match_count = documents['matches']
    docids = documents['results'].collect{|doc| doc['docid']}
    bookids = docids.collect do |docid|
      arr = docid.split('_')
      arr.first == "b" ? arr.last.to_i : nil
    end
    bookids.compact!
    @books = Book.where(:id.in => bookids).page(params[:page]).per(10)
  end
  
  def autocomplete
    data = @indextank.search "#{params[:query]} type:book"
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
