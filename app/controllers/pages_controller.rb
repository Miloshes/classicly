class PagesController < ApplicationController

  def main
    @featured_books = Collection.where(:name => 'Best Of').first().books.page(params[:page]).per(10)
  end

end
