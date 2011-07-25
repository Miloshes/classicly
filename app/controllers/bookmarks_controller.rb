class BookmarksController < ApplicationController

  def create
    message = ""

    if current_login && current_library.library_books.exists?(:book_id => params[:book_id])
      book_from_library  = LibraryBook.find_by_library_id_and_book_id(current_library.id, params[:book_id])
      book_from_library.bookmarks.find_or_create_by_page_number(params[:page])
      message = true
    else
      message = false
    end

    render :text => message
  end

  def destroy
    if current_login && current_library.library_books.exists?(:book_id => params[:id])
      book_from_library  = LibraryBook.find_by_library_id_and_book_id(current_library.id, params[:id])
      book_from_library.bookmarks.find_by_page_number(params[:page]).delete
    end
    render :text =>  true
  end

end
