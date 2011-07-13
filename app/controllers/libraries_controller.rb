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
  
  # NOTE: should be called after the Facebook Login happens
  def handle_facebook_login
    # == save the library (which was just a session) into the DB
    
    # the current user is the owner of the library to be created
    current_library.user = current_login
    current_library.save
    
    # == update the current page
    render :action => 'handle_facebook_login'
  end

end
