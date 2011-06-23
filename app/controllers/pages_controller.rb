class PagesController < ApplicationController
  def about
    
  end

  def audiobook_authors
    @featured = Collection.of_type('audiobook').collection_type('author').random(1).first
    @collections = Collection.where(:id.not_eq => @featured.id).of_type('audiobook').collection_type('author').order('name asc').page(params[:page]).per(12)
    render 'authors', :layout => 'audibly'
  end
  
  def audio_collections
    @featured = Collection.of_type('audiobook').collection_type('collection').random(1).first
    @collections = Collection.where(:id.not_eq => @featured.id).of_type('audiobook').collection_type('collection').order('name asc').page(params[:page]).per(12)
    render 'collections', :layout => 'audibly'
  end
    
  def authors
    @featured = Collection.of_type('book').collection_type('author').random(1).first
    @collections = Collection.where(:id.not_eq => @featured.id).of_type('book').collection_type('author').order('name asc').page(params[:page]).per(12)
  end

  def collections
    @featured = Collection.of_type('book').collection_type('collection').random(1).select('id, name, parsed_description, cached_slug, book_type').first
    @collections = Collection.where(:id.not_eq => @featured.id).of_type('book').collection_type('collection').order('name asc').page(params[:page]).per(12)
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