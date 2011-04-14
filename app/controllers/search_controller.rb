class SearchController < ApplicationController
  before_filter :find_author_collections, :only => [:show, :download]
  before_filter :find_genre_collections, :only => [:show, :download]

  def show
    @search = params[:term]
    @books = Book.search(@search, params[:page])
    @popular_books = Book.blessed.random(8)
  end

end
