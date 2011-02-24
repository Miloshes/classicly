class PagesController < ApplicationController
  
  def main
    @featured_books = Collection.where(:name => 'Best Of').first().books
  end
  
end
