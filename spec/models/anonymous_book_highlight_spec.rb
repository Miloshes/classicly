require 'spec_helper'

describe AnonymousBookHighlight do
  
  before(:each) do
    @book  = mock_model(Book)
    @login = mock_model(Login, :fb_connect_id => "123", :ios_device_id => "asd")

    Login.stub_chain(:where, :first).and_return(@login)

    @book_highlight = AnonymousBookHighlight.new(
      :first_character => 0,
      :last_character  => 9,
      :book            => @book,
      :ios_device_id   => @login.ios_device_id
    )
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
    
    it "should have an ios_device_id assigned to it" do
      @book_highlight.ios_device_id = nil
      @book_highlight.should_not be_valid
    end
  end
  
  describe "getting created via a Web API call" do
    
    before(:each) do
      @api_call_params = {
        "device_id"       => "ASDASD",
        "book_id"         => 30,
        "action"          => "register_book_highlight",
        "first_character" => 0,
        "last_character"  => 29,
        "content"         => "The rabbit went down the hole.",
        "timestamp"       => "Thu Feb 10 15:09:59 +0100 2011"
      }
    end
    
    context "" do
      it "shouldn't create the highlight" do
        AnonymousBookHighlight.create_or_update_from_ios_client_data()
      end
    end
    
  end
  
end
