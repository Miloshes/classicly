class PagesController < ApplicationController

  def main
    @related_books = Book.blessed.random(8)
    @featured_books = Book.blessed.available.with_description.random(5)
    #clear session return_to to avoid redirecting incorrectly
    session[:return_to] = nil
  end

end
