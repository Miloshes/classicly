require 'spec_helper'

describe BookPage do

  before(:each) do
    @book = mock_model(Book)
    @book_page = BookPage.new(:first_character => 0, :last_character => 9, :page_number => 1, :book => @book)
  end
  
  context "when getting created" do
    it "should have the first_character and last_character attributes set" do
      @book_page.should be_valid
      
      @book_page.first_character = nil
      @book_page.should_not be_valid
      
      @book_page.first_character = 1
      
      @book_page.last_character = nil
      @book_page.should_not be_valid
    end
    
    it "should have a book assigned to it" do
      @book_page.book = nil
      
      @book_page.should_not be_valid
    end
    
    it "should have it's page_number attribute set" do
      @book_page.page_number = nil
      
      @book_page.should_not be_valid
    end
  end
  
  describe "doing page rendering" do
    it "should be able to render itself based on the book's content" do
      fake_content = "1234567890123"
      @book.stub!(:is_rendered_for_online_reading?).and_return(false)
      
      expect {
        @book_page.render_page_content_from(fake_content)
      }.to change(@book_page, :content).to("1234567890")
    end
    
    
    it "shouldn't do any rendering when the book is already rendered" do
      fake_content = "1234567890123"
      @book.stub!(:is_rendered_for_online_reading?).and_return(true)
      
      expect {
        @book_page.render_page_content_from(fake_content)
      }.to_not change(@book_page, :content)
    end
  end
    
  it "should be able to wipe it's content when asked" do
    @book_page.content = "123"
    
    expect {
      @book_page.wipe_page_content!
    }.to change(@book_page, :content).to(nil)
  end

end