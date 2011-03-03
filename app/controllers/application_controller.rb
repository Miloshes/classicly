class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :find_covers
  before_filter :find_author_collections
  before_filter :find_genre_collections

  protected
  def find_covers
    @covers = Book.where({:blessed => true}).limit(8)
  end

  def find_author_collections
    @author_collections = Collection.where({:collection_type => 'author'}).limit(10) 
  end

  def find_genre_collections
    @genre_collections = Collection.where({:collection_type => ['genre', 'collection']}).limit(10)
  end
end
