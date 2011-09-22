require "spec_helper"

describe WebApiController, "(API calls - notes and highlights registration)" do
  
  before(:each) do
    @book = mock_model(Book)
    Book.stub!(:find).and_return(@book)
    
    @login = mock_model(Login, :fb_connect_id => "123", :ios_device_id => "asd")
    Login.stub_chain(:where, :first).and_return(@login)

    # NOTE: device_id is a must parameter. It identifies users for storing anonymous highlights, and for normal highlights
    # it enables the model to fall back to creating an anonymous one if the user registartion failed
    @api_call_params = {
      "device_id"       => @login.ios_device_id,
      "book_id"         => @book.id,
      "action"          => "register_book_highlight",
      "first_character" => 0,
      "last_character"  => 29,
      "content"         => "The rabbit went down the hole.",
      "timestamp"       => (Time.now).to_s(:db)
    }
  end
  
  context "working with anonymous highlights" do
    
    before(:each) do
      # a valid model - for checking the update
      @anonymous_book_highlight = AnonymousBookHighlight.new(
        :first_character => 0,
        :last_character  => 9,
        :book            => @book,
        :ios_device_id   => @login.ios_device_id,
        :created_at      => Time.now
      )
    end
    
    it "should be able to register one given the book and the device ID" do
      post "create", :json_data => @api_call_params.to_json

      response.body.should == "SUCCESS"
      AnonymousBookHighlight.should have(1).record
      BookHighlight.should have(0).records
    end
    
    it "should be able to update it" do
      # future timestamp, so the update actually happens
      new_timestamp = (Time.now + 10.minutes).to_s(:db)
      @api_call_params["timestamp"] = new_timestamp
      
      AnonymousBookHighlight.stub_chain(:where, :first).and_return(@anonymous_book_highlight)
      
      @anonymous_book_highlight.should_receive(:update_attributes)
      
      post "create", :json_data => @api_call_params.to_json
    end
    
  end
  
  context "working with regular (created by registered users) highlights" do

    before(:each) do
      @api_call_params["user_fbconnect_id"] = @login.fb_connect_id
      
      # a valid model - for checking the update
      @book_highlight = BookHighlight.new(
        :first_character => 0,
        :last_character  => 9,
        :book            => @book,
        :user            => @login,
        :fb_connect_id   => @login.fb_connect_id,
        :created_at      => Time.now
      )
    end
    
    it "should be able to register one given the book and the user's facebook ID" do
      post "create", :json_data => @api_call_params.to_json

      response.body.should == "SUCCESS"
      BookHighlight.should have(1).records
      AnonymousBookHighlight.should have(0).records
    end
    
    it "should create an anonymous highlight instead if by some mistake the user is not registered yet" do
      # faking that the user doesn't exist
      Login.stub_chain(:where, :first).and_return(nil)
      
      post "create", :json_data => @api_call_params.to_json

      response.body.should == "SUCCESS"
      BookHighlight.should have(0).records
      AnonymousBookHighlight.should have(1).record
    end
    
    it "should be able to update it" do
      # future timestamp, so the update actually happens
      new_timestamp = (Time.now + 10.minutes).to_s(:db)
      @api_call_params["timestamp"] = new_timestamp
      
      BookHighlight.stub_chain(:where, :first).and_return(@book_highlight)
      
      @book_highlight.should_receive(:update_attributes)
      
      post "create", :json_data => @api_call_params.to_json
    end

  end 
  
end

describe WebApiController, "(API calls - notes and highlights related queries)" do
  
  before(:each) do
    @book  = FactoryGirl.create(:book)
    @login = FactoryGirl.create(:login)

    # NOTES: documentation
    @api_call_params = {
      "device_id"         => @login.ios_device_id,
      "book_id"           => @book.id,
      "action"            => "get_book_highlights_for_user_for_book",
      "structure_version" => "1.2"
    }
  end
  
  describe "getting the list of the highlights for a user and a book" do
  
    it "should work when the user hasn't registered and has only anonymous highlights" do
      highlight  = FactoryGirl.create(:anonymous_highlight_with_note, :book => @book, :ios_device_id => @login.ios_device_id)
      highlight2 = FactoryGirl.create(:anonymous_highlight_just_note, :book => @book, :ios_device_id => @login.ios_device_id)

      post "query", :json_data => @api_call_params.to_json
      
      parsed_response = ActiveSupport::JSON.decode(response.body)
      
      # We're expecting something like this:
      # [
      #   {"first_character"=>0, "last_character"=>29, "content"=>"text", "created_at"=>"2011-09-21T12:52:13Z", "origin_comment"=>"text"},
      #   {"first_character"=>1, "last_character"=>1, "content"=> nil, "created_at"=>"2011-09-21T12:52:13Z", "origin_comment"=>"text"}
      # ]
      
      parsed_response.class.should == Array
      parsed_response.first.keys.sort.should == ["content", "created_at", "first_character", "last_character", "origin_comment"]
    end
  
    it "should work when the user is registered" do
      highlight  = FactoryGirl.create(:highlight_with_note, :book => @book, :user => @login)
      highlight2 = FactoryGirl.create(:highlight_just_note, :book => @book, :user => @login)

      post "query", :json_data => @api_call_params.to_json
      
      parsed_response = ActiveSupport::JSON.decode(response.body)
      
      # We're expecting something like this:
      # [
      #   {"first_character"=>0, "last_character"=>29, "content"=>"text", "created_at"=>"2011-09-21T12:52:13Z", "origin_comment"=>"text"},
      #   {"first_character"=>1, "last_character"=>1, "content"=> nil, "created_at"=>"2011-09-21T12:52:13Z", "origin_comment"=>"text"}
      # ]
      
      parsed_response.class.should == Array
      parsed_response.first.keys.sort.should == ["content", "created_at", "first_character", "last_character", "origin_comment"]
    end
  
  end
  
end