require "spec_helper"

describe WebApiController, "(API calls - notes and highlights registration)" do
  
  before(:each) do
    @author    = mock_model(Author, :name => "Victor Hugo", :cached_slug => "victor-hugo")
    @book      = mock_model(Book, :author => @author, :title => "Les miserables", :pretty_title => "Les miserables", :cached_slug => "les-miserables")
    @highlight = mock_model(BookHighlight, :content => "gone away", :cached_slug => "gone-away")
    
    @book.stub!(:pretty_download_formats).and_return(["PDF", "Kindle", "Rtf"])
    Book.stub!(:find).and_return(@book)
    
    @ios_device = mock_model(IosDevice, :original_udid => "original_udid1", :ss_udid => "ss_udid1")
    @login      = mock_model(Login, :fb_connect_id => "123", :ios_device => @ios_device, :email => "test@test.com")

    # NOTE: device_id is a must parameter. It identifies users for storing anonymous highlights, and for normal highlights
    # it enables the model to fall back to creating an anonymous one if the user registartion failed
    @api_call_params = {
      "device_ss_id"    => @login.ios_device.ss_udid,
      "book_id"         => @book.id,
      "action"          => "register_book_highlight",
      "first_character" => 0,
      "last_character"  => 29,
      "content"         => "The rabbit went down the hole.",
      "timestamp"       => (Time.now).to_s(:db),
      "apple_id"        => "364612911"
    }
  end
  
  context "working with anonymous highlights" do
    
    context "when doing registration" do
    
      it "should be able to register one given the book and the device ID" do
        post "create", :json_data => @api_call_params.to_json
      
        response.should be_success
        AnonymousBookHighlight.should have(1).record
        BookHighlight.should have(0).records
      end
    
      it "should return the URL for the highlight's public page and the twitter and facebook share message" do
        post "create", :json_data => @api_call_params.to_json
      
        parsed_response = ActiveSupport::JSON.decode(response.body)
      
        parsed_response.class.should == Hash
        parsed_response["public_highlight_url"].should_not be_blank
        parsed_response["twitter_message"].should_not be_blank
        parsed_response["facebook_message"].should_not be_blank
      end
    
    end
    
    context "when doing update to an existing one" do
      
      before(:each) do
        # a valid model - for checking the update
        @anonymous_book_highlight = FactoryGirl.create(:anonymous_book_highlight,
          :first_character  => 0,
          :last_character   => 9,
          :content          => "content 12",
          :book             => @book,
          :ios_device_ss_id => @login.ios_device.ss_udid,
          :created_at       => Time.now,
          :cached_slug      => "content-12"
        )
      end
    
      it "should be able to update it" do
        # future timestamp, so the update actually happens
        new_timestamp = (Time.now + 10.minutes).to_s(:db)
        @api_call_params["timestamp"] = new_timestamp
      
        AnonymousBookHighlight.stub_chain(:where, :first).and_return(@anonymous_book_highlight)
      
        @anonymous_book_highlight.should_receive(:update_attributes)
      
        post "create", :json_data => @api_call_params.to_json
      end
    
      it "should return the URL for the highlight's public page and the twitter and facebook share message after the update" do
        # future timestamp, so the update actually happens
        new_timestamp = (Time.now + 10.minutes).to_s(:db)
        @api_call_params["timestamp"] = new_timestamp
      
        AnonymousBookHighlight.stub_chain(:where, :first).and_return(@anonymous_book_highlight)
        
        post "create", :json_data => @api_call_params.to_json
      
        parsed_response = ActiveSupport::JSON.decode(response.body)
      
        parsed_response.class.should == Hash
        parsed_response["public_highlight_url"].should_not be_blank
        parsed_response["twitter_message"].should_not be_blank
        parsed_response["facebook_message"].should_not be_blank
      end
      
    end
    
  end
  
  context "working with regular (created by registered users) highlights" do
    
    context "when doing registration" do
      
      it "should be able to register one given the book and the user's facebook ID" do
        @api_call_params["user_fbconnect_id"] = @login.fb_connect_id
        
        Login.should_receive(:find_by_fb_connect_id).and_return(@login)
        
        post "create", :json_data => @api_call_params.to_json

        response.should be_success
        BookHighlight.should have(1).records
        AnonymousBookHighlight.should have(0).records
      end
      
      it "should be able to register one given the book and the user's email address" do
        @api_call_params["user_email"] = @login.email
        
        Login.should_receive(:find_by_email).and_return(@login)
        
        post "create", :json_data => @api_call_params.to_json

        response.should be_success
        BookHighlight.should have(1).records
        AnonymousBookHighlight.should have(0).records
      end

      it "should create an anonymous highlight instead if by some mistake the user is not registered yet" do
        # faking that the user doesn't exist, despite the right parameters being sent
        @api_call_params["user_fbconnect_id"] = @login.fb_connect_id
        @api_call_params["user_email"] = @login.email
        
        Login.stub!(:find_by_fb_connect_id).and_return(nil)
        Login.stub!(:find_by_email).and_return(nil)

        post "create", :json_data => @api_call_params.to_json

        response.should be_success
        BookHighlight.should have(0).records
        AnonymousBookHighlight.should have(1).record
      end
      
      it "should return the URL for the highlight's public page and the twitter and facebook share message" do
        @api_call_params["user_fbconnect_id"] = @login.fb_connect_id
        
        Login.should_receive(:find_by_fb_connect_id).and_return(@login)
        
        post "create", :json_data => @api_call_params.to_json

        parsed_response = ActiveSupport::JSON.decode(response.body)

        parsed_response.class.should == Hash
        parsed_response["public_highlight_url"].should_not be_blank
        parsed_response["twitter_message"].should_not be_blank
        parsed_response["facebook_message"].should_not be_blank
      end
      
    end
    
    context "when doing update to an existing one" do
      
      before(:each) do
        @book_highlight = FactoryGirl.create(:book_highlight,
          :first_character => 0,
          :last_character  => 9,
          :book            => @book,
          :user            => @login,
          :fb_connect_id   => @login.fb_connect_id,
          :created_at      => Time.now
        )
        
        @api_call_params["user_fbconnect_id"] = @login.fb_connect_id
        Login.stub!(:find_by_fb_connect_id).and_return(@login)
      end
      
      it "should be able to update it" do
        # future timestamp, so the update actually happens
        new_timestamp = (Time.now + 10.minutes).to_s(:db)
        @api_call_params["timestamp"] = new_timestamp

        BookHighlight.stub_chain(:where, :first).and_return(@book_highlight)

        @book_highlight.should_receive(:update_attributes)
        
        post "create", :json_data => @api_call_params.to_json
      end

      it "should return the URL for the highlight's public page and the twitter and facebook share message after the update" do
        # future timestamp, so the update actually happens
        new_timestamp = (Time.now + 10.minutes).to_s(:db)
        @api_call_params["timestamp"] = new_timestamp

        BookHighlight.stub_chain(:where, :first).and_return(@book_highlight)

        post "create", :json_data => @api_call_params.to_json

        parsed_response = ActiveSupport::JSON.decode(response.body)

        parsed_response.class.should == Hash
        parsed_response["public_highlight_url"].should_not be_blank
        parsed_response["twitter_message"].should_not be_blank
        parsed_response["facebook_message"].should_not be_blank
      end
      
    end

  end 
  
end

describe WebApiController, "(API calls - notes and highlights related queries)" do
  
  before(:each) do
    @book       = FactoryGirl.create(:book)
    @login      = FactoryGirl.create(:login, :fb_connect_id => "123")

    # NOTES: documentation
    @api_call_params = {
      "device_ss_id" => @login.ios_device.ss_udid,
      "book_id"      => @book.id,
      "action"       => "get_book_highlights_for_user_for_book"
    }
  end
  
  describe "getting the list of the highlights for a user and a book" do

    context "when the user hasn't registered and has only anonymous highlights" do

      it "should return the list of those" do
        highlight  = FactoryGirl.create(:anonymous_book_highlight,
            :book             => @book,
            :ios_device_ss_id => @login.ios_device.ss_udid,
            :first_character  => 0,
            :last_character   => 6,
            :content          => "content"
          )
        highlight2 = FactoryGirl.create(:anonymous_book_highlight_with_note,
            :book             => @book,
            :ios_device_ss_id => @login.ios_device.ss_udid
          )

        post "query", :json_data => @api_call_params.to_json

        parsed_response = ActiveSupport::JSON.decode(response.body)

        # We're expecting something like this:
        # [
        #   {"first_character"=>0, "last_character"=>29, "content"=>"text", "created_at"=>"2011-09-21T12:52:13Z", "origin_comment"=>"text"},
        #   {"first_character"=>1, "last_character"=>1, "content"=> nil, "created_at"=>"2011-09-21T12:52:13Z", "origin_comment"=>"text"}
        # ]

        parsed_response.class.should == Array
        parsed_response.count.should == 2
        parsed_response.first.keys.sort.should == ["content", "created_at", "first_character", "last_character", "origin_comment"]
      end

    end
    
    context "when the user is identified by his email address" do
      
      it "should return the list of those" do
        # device ID is always there as a last resort, but we're removing it for the sake of the test
        @api_call_params.delete("device_ss_id")
        @api_call_params["user_email"] = @login.email
        
        highlight  = FactoryGirl.create(:book_highlight, :book => @book, :user => @login)
        highlight2 = FactoryGirl.create(:book_highlight_with_note, :book => @book, :user => @login)

        post "query", :json_data => @api_call_params.to_json

        parsed_response = ActiveSupport::JSON.decode(response.body)

        # We're expecting something like this:
        # [
        #   {"first_character"=>0, "last_character"=>29, "content"=>"text", "created_at"=>"2011-09-21T12:52:13Z", "origin_comment"=>"text"},
        #   {"first_character"=>1, "last_character"=>1, "content"=> nil, "created_at"=>"2011-09-21T12:52:13Z", "origin_comment"=>"text"}
        # ]

        parsed_response.class.should == Array
        parsed_response.count.should == 2
        parsed_response.first.keys.sort.should == ["content", "created_at", "first_character", "last_character", "origin_comment"]
      end
      
    end
    
    context "when the user is identified by his Facebook ID" do
      
      it "should return the list of those" do
        # device ID is always there as a last resort, but we're removing it for the sake of the test
        @api_call_params.delete("device_ss_id")
        @api_call_params["user_fbconnect_id"] = @login.fb_connect_id
        
        highlight  = FactoryGirl.create(:book_highlight, :book => @book, :user => @login)
        highlight2 = FactoryGirl.create(:book_highlight_with_note, :book => @book, :user => @login)

        post "query", :json_data => @api_call_params.to_json

        parsed_response = ActiveSupport::JSON.decode(response.body)

        # We're expecting something like this:
        # [
        #   {"first_character"=>0, "last_character"=>29, "content"=>"text", "created_at"=>"2011-09-21T12:52:13Z", "origin_comment"=>"text"},
        #   {"first_character"=>1, "last_character"=>1, "content"=> nil, "created_at"=>"2011-09-21T12:52:13Z", "origin_comment"=>"text"}
        # ]

        parsed_response.class.should == Array
        parsed_response.count.should == 2
        parsed_response.first.keys.sort.should == ["content", "created_at", "first_character", "last_character", "origin_comment"]
      end
      
    end
  
  end
  
end