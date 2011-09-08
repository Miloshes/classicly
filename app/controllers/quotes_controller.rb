class QuotesController < ApplicationController

  def show
    @quote = Quote.find(params[:id])
    @books = @quote.collection.books.limit(3)
  end
end
