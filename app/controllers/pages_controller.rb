class PagesController < ApplicationController

  def main
    @related_books = Book.random_blessed_books(8)
    @featured_books = Collection.where(:name => 'Best Of').first().books.available.with_description.page(params[:page]).per(5)
  end

end
