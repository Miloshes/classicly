class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :find_author_collections
  before_filter :find_genre_collections

  protected

  def find_author_collections
    @author_collections = Collection.where({:collection_type => 'author'})
  end

  def find_genre_collections
    @genre_collections = Collection.where({:collection_type => ['genre', 'collection']})
  end
end
