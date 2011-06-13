class CollectionsController < ApplicationController
  
  # receives an array of collection ids separated by commas
  # return a json array with collection id and its books
  def collection_json_books
    # cache response for a week
    response.headers['Cache-Control'] = "public, max-age=#{7*24*60*60}"
    collection_ids = params[:id].split( ',' )
    data = Collection.get_collection_books_in_json(collection_ids, params[:type], params[:total_books].to_i)
    render :json => data.to_json
  end
  
end