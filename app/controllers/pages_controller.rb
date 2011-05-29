class PagesController < ApplicationController
  def audiobook_authors
    @collections = Collection.of_type('audiobook').collection_type('author').random(10)
    @featured = @collections.first
    @viewing_audibly = true
    render 'authors', :layout => 'audibly'
  end
  
  def audio_collections
    @collections = Collection.of_type('audiobook').collection_type('collection').random(10)
    @featured = @collections.first
    @viewing_audibly = true
    render 'collections', :layout => 'audibly'
  end
    
  def authors
    @collections = Collection.book_type.by_author.random(10).select('id, description, name, cached_slug')
    @featured = @collections.first
  end

  def collections
    @collections = Collection.book_type.by_collection.random(10)
    @featured = @collections.first
  end
  

  def main
  end

  def random_json_books
    books = Book.blessed.no_squat_image.select('books.id, author_id, cached_slug, pretty_title').random(params[:total_books].to_i)
    render :json => Book.hashes_for_JSON(books)
  end
end
