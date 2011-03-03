class PagesController < ApplicationController

  def main
    @related_books = Book.random_blessed_books(8)
    @featured_books = Collection.where(:name => 'Best Of').first().books.page(params[:page]).per(10)
  end

end
