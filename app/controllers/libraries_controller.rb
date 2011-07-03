class LibrariesController < ApplicationController
  
  def show
    @books = Book.where(:title.matches => "Poems").all()
  end
  
  def add_book
    
  end
  
end
