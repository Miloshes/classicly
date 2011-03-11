class PagesController < ApplicationController

  def main
    @related_books = Book.blessed.random(8)
    @featured_books = Book.blessed.available.with_description.random(8)
  end

end
