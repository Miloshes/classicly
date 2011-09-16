class QuotesController < ApplicationController

  def show
    @collection = Collection.find(params[:id])
    @quote      = @collection.quotes.find_by_cached_slug(params[:quote_slug])
    @books      = @quote.collection.books.limit(3)
  end

end
