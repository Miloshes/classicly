class CollectionsController < ApplicationController
  
  # receives an array of collection ids separated by comas
  # return a json array with collection id and its books
  def collection_json_books 
    collection_ids = params[:id].split( ',' )
    data = Collection.get_collection_books_in_json collection_ids, params[:type]
    render :json => data.to_json
  end
end