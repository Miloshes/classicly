class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :find_author_collections
  before_filter :find_genre_collections
  before_filter :set_return_to
  protected

  def find_author_collections
    @author_collections = Collection.where({:collection_type => 'author', :book_type => 'book'})
  end

  def find_genre_collections
    @genre_collections = Collection.where({:collection_type => 'collection', :book_type => 'book'})
  end

  def redirect_back_or_default
    redirect_to session[:return_to] || root_path
  end
  
  def set_return_to
    session['return_to'] = (request.request_uri =~ /\/\w+/) && !(request.request_uri =~ /\/auth\/facebook/)? request.request_uri : session['return_to']
  end
end
