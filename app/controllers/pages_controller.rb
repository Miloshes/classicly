class PagesController < ApplicationController

  def main
    @related_books = Book.random_blessed_books(8)
    @featured_books = Collection.where(:name => 'Best Of').first().books.blessed.available.with_description.limit(5)
  end

end
