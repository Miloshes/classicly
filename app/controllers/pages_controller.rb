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
    @featured = Collection.of_type('book').collection_type('author').random(1).first
    @featured_collections = Collection.where(:id.not_eq => @featured.id).book_type.by_author.random(3)
    featured_ids = [@featured.id]
    featured_ids += @featured_collections.map(&:id)
    @other_collections = Collection.where(:id.not_in => featured_ids).book_type.by_author
  end

  def collections
    @featured = Collection.of_type('book').collection_type('collection').random(1).first
    @featured_collections = Collection.where(:id.not_eq => @featured.id).of_type('book').collection_type('collection').random(3)
    featured_ids = [@featured.id]
    featured_ids += @featured_collections.map(&:id)
    @other_collections = Collection.where(:id.not_in => featured_ids).of_type('book').collection_type('collection')
  end
  

  def main
  end
  
  def privacy
    
  end

  def random_json_books
    books = Book.blessed.no_squat_image.select('books.id, author_id, cached_slug, pretty_title').random(params[:total_books].to_i)
    render :json => Book.hashes_for_JSON(books)
  end
end
