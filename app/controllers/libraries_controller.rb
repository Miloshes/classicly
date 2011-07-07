class LibrariesController < ApplicationController
  
  def show
    current_library.books = Book.where(:title.matches => "Poems").all()
    @books = current_library.books
  end
  
  def add_book
    
  end
  
end
