class LibrariesController < ApplicationController

  def show
    # We're listing the library, but the previous action might've just put a book in here which we get to know via a session
    if session[:new_book_in_library]
      @new_book_in_library = Book.find(session[:new_book_in_library])

      current_library.add_book(@new_book_in_library)

      @download_format = session[:download_format_for_the_new_book]

      session[:new_book_in_library] = nil
      session[:download_format_for_the_new_book] = nil
    end

    @books = current_library.books
  end

  # NOTE: should be called after the Facebook Login happens
  def handle_facebook_login
    # register the library
    current_library.register_for(current_login)
    # update the current page
    render :action => 'handle_facebook_login'
  end

end
