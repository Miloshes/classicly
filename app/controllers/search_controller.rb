class SearchController < ApplicationController

  def show
    @search = params[:term]
    @books = Book.search(@search, params[:page])
  end

end
