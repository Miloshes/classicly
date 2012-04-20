class QuotesController < ApplicationController

  def show
    @collection = Collection.includes(:quotes).find(params[:id])
    @quote      = @collection.quotes.find_by_cached_slug(params[:quote_slug])
    status, @books = @quote.nil? ? [404, @collection.books.limit(3)] : [200, @quote.collection.books.limit(3)]
    render :show, status: status
  end
end
