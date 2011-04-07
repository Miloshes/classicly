class SearchController < ApplicationController
  before_filter :find_author_collections, :only => [:show, :download]
  before_filter :find_genre_collections, :only => [:show, :download]

  def show
    @search = params[:term]
    @books = Book.search(@search, params[:page])
  end

end
