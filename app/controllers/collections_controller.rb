class CollectionsController < ApplicationController
  
  # receives an array of collection ids separated by comas
  # return a json array with collection id and its books
  def json_books_for_authors_collection
    data = []
    collection_ids = params[:id].split( ',' )
    collection_ids.each do |id|
      # find the collection:
      current = Collection.find id
      # get 5 books to show:
      books = current.books.no_squat_image.limit( 5 )
      # create the books data to be converted in json: 
      books_hash_array = books.map do |book|
        author_slug = Author.where(:id => book.author_id).select('cached_slug').first.cached_slug
        { :id => book.id, :slug => book.cached_slug, :author_slug => author_slug }
      end
      # add the collection id to the data to be sent:
      data << {:collection_id => id, :books => books_hash_array} 
    end
    render :json => data.to_json
  end
  
  def json_books_for_collection
    
  end
end