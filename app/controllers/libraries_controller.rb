class LibrariesController < ApplicationController

  def show
    current_library.books = Book.where(:title.matches => "Dracula").all()
    # we get here via a redirect. We're listing the library, but the previous action might've just put a book in here which we get to know via a session
    if session[:new_book_in_library]
      @new_book_in_library = Book.find(session[:new_book_in_library])
      current_library.books << @new_book_in_library
      @download_format = session[:download_format_for_the_new_book]
      session[:new_book_in_library] = nil
      session[:download_format_for_the_new_book] = nil
      session[:library] = nil # otherwise, it will create a dumpfile error
    end
    @books = current_library.books
  end

end
