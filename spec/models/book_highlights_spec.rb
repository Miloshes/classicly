require 'spec_helper'

describe BookHighlights do
  
  before(:each) do
    @book = mock_model(Book)
    @book_highlight = BookHighlight.new(:first_character => 0, :last_character => 9, :book => @book)
  end
  
  context "when getting created" do
    it "should have the first_character and last_character attributes set" do
      @book_highlight.should be_valid
      
      @book_highlight.first_character = nil
      @book_highlight.should_not be_valid
      
      @book_highlight.first_character = 1
      
      @book_highlight.last_character = nil
      @book_highlight.should_not be_valid
    end
    
    it "should have a book assigned to it" do
      @book_highlight.book = nil
      
      @book_highlight.should_not be_valid
    end
  end
  
end
