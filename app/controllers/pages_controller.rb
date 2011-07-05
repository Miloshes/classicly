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
    @collections = Collection.where(:id.not_eq => @featured.id).of_type('book').collection_type(['collection', 'genre']).order('name asc').page(params[:page]).per(12)
  end
  
  def main
    @featured_book = Book.blessed.select("books.id, author_id, cached_slug, pretty_title").random(1).first
    @column_books = Book.blessed.select("books.id, author_id, cached_slug, pretty_title").random(9)
  end
  
  def privacy
  end
end