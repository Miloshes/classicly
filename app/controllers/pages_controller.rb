class PagesController < ApplicationController
  def about
  end

  def audiobook_authors
    @featured     = Collection.of_type('audiobook').collection_type('author').random(1).first if params[:page].nil?
    @collections  = Collection.of_type('audiobook').collection_type('author').order('name asc').page(params[:page]).per(12)
    @collections  = @collections.where(:id.not_eq => @featured.id) if @featured
    render 'authors', :layout => 'audibly'
  end

  def audio_collections
    @featured     = Collection.of_type('audiobook').collection_type(['collection', 'genre']).random(1).first if params[:page].nil?
    @collections  = Collection.of_type('audiobook').collection_type(['collection', 'genre']).order('name asc').page(params[:page]).per(12)
    @collections  = @collections.where(:id.not_eq => @featured.id) if @featured
    render 'collections', :layout => 'audibly'
  end

  def authors
    @featured     = Collection.find_author_book_collections.random(1).first if params[:page].nil?
    @collections  = Collection.find_author_book_collections.order('name asc').page(params[:page]).per(12)
    @collections  = @collections.where(:id.not_eq => @featured.id) if @featured
  end

  def collections
    @featured     = Collection.find_book_collections_and_genres.random(1).select('id, name, parsed_description, cached_slug, book_type').first if params[:page].nil?
    @collections  = Collection.find_book_collections_and_genres.order('name asc').page(params[:page]).per(12)
    @collections  = @collections.where(:id.not_eq => @featured_collection.id) if @featured_collection
  end

  def main
    @featured_book = Book.blessed.select("books.id, author_id, cached_slug, pretty_title").random(1).first
    @column_books = Book.blessed.select("books.id, author_id, cached_slug, pretty_title").random(9)
  end

  def privacy
  end
end
