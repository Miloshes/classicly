require 'spec_helper'

describe Library do
  
  describe "adding a book to the library" do
    context "when it's a book that' not in the Library" do
      pending "should add that book to the Library"
      pending "should increase the books_downloaded attibute"
    end
    
    context "when it's a book that's already in the Library" do
      pending "shouldn't add that book"
      pending "shouldn't increase the books_downloaded attribute"
    end
  end
  
  describe "destroying the Library" do
    pending "should destroy it's associated LibraryBook and LibraryAudiobook objects too"
  end
  
  describe "registration" do
    pending "should belong to a user, and should return true when asked if it's registered"
  end
  
  describe "#last_read_book" do
    pending "should always return the book that was last opened"
  end
  
end
