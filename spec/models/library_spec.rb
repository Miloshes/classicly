require 'spec_helper'

describe Library do

  before(:each) do
    @library = Library.new
    
    @book1 = Fabricate(:book, :title => "Dracula")
    @book2 = Fabricate(:book, :title => "Sherlock Holmes")
    
    # book1 is added to the Library, book2 is a new book
    @library.add_book(@book1)
  end
  
  describe "adding a book to the library" do
    context "when it's a book that's not in the Library" do
      
      it "should add that book to the Library" do
        # make sure it's a new book
        @library.books.should_not include(@book2)
        
        lambda {
          @library.add_book(@book2)
        }.should change(@library.books, :size).by(1)
        
        @library.books.should include(@book2)
      end
      
      it "should increase the books_downloaded attibute" do
        lambda {
          @library.add_book(@book2)
        }.should change(@library, :books_downloaded).by(1)
      end
      
    end
    
    context "when it's a book that's already in the Library" do
      
      it "shouldn't add that book" do
        # make sure it's a book that's already added
        @library.books.should include(@book1)
        
        lambda {
          @library.add_book(@book1)
        }.should_not change(@library.books, :size)
      end
      
      it "shouldn't increase the books_downloaded attribute" do
        lambda {
          @library.add_book(@book1)
        }.should_not change(@library, :books_downloaded)
      end
      
    end
  end
  
  describe "destroying the Library" do
    
    # TODO: update when we're supporting adding audiobooks to the Library
    it "should destroy it's associated LibraryBook and LibraryAudiobook objects too" do
      # we make sure the association record is there
      @library.fetch_record_for_book(@book1).should be_an_instance_of(LibraryBook)
      
      @library.destroy
      
      @library.fetch_record_for_book(@book1).should be_nil
    end
    
  end
  
  describe "#register_for" do
    
    before(:each) do
      @user = Fabricate(:login)
    end
    
    it "should associate the Library with a user" do
      @library.user.should be_nil
      
      @library.register_for(@user)
      
      @library.user.should == @user
    end
    
    it "should change it's unregistered flag to false" do
      lambda {
        @library.register_for(@user)
      }.should change(@library, :unregistered).from(true).to(false)
    end
    
  end
  
  describe "#last_read_book" do
    it "should always return the book that was last opened" do
      # add the new book to the library
      @library.add_book(@book2)
      
      # actually open it
      library_record = @library.fetch_record_for_book(@book2)
      library_record.update_attributes(:last_opened => Time.now)
      
      @library.last_read_book.should == @book2
    end
  end
  
end
