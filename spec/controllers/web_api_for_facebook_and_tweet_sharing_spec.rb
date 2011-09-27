require "spec_helper"

# NOTE: for sharing Notes & Highlights via Facebook and Tweet, look for API calls - Notes & Highlights
describe WebApiController, "(API calls - Facebook & Tweet sharing related)" do
  
  before(:each) do
    @author    = mock_model(Author, :name => "Victor Hugo", :cached_slug => "victor-hugo")
    @book      = mock_model(Book, :author => @author, :title => "Les miserables", :pretty_title => "Les miserables", :cached_slug => "les-miserables")
    @audiobook = mock_model(Audiobook,
        :author => @author,
        :title => "Les miserables audiobook",
        :pretty_title => "Les miserables audiobook",
        :cached_slug => "les-miserables-audiobook"
      )
    @highlight = mock_model(BookHighlight, :content => "gone away", :cached_slug => "gone-away")
    
    @book.stub!(:pretty_download_formats).and_return(["PDF", "Kindle", "Rtf"])
    Book.stub!(:find).and_return(@book)
    
    @audiobook.stub!(:pretty_download_formats).and_return(["mp3"])
    Audiobook.stub!(:find).and_return(@audiobook)
    
    @login = mock_model(Login, :fb_connect_id => "123", :ios_device_id => "asd")
    Login.stub_chain(:where, :first).and_return(@login)
  end
  
  describe "getting the share message for a book" do
    
    before(:each) do
      @api_call_params = {
        "book_id"         => @book.id,
        "action"          => "get_tweet_and_facebook_share_texts",
        "platform"        => "twitter",
        "message_type"    => "book share"
      }
      
      @share_message_handler = ShareMessageHandler.new
      ShareMessageHandler.stub!(:new).and_return(@share_message_handler)
    end
    
    it "should take into account the platform" do
      @api_call_params["platform"] = "twitter"
      @share_message_handler.should_receive(:get_message_for).with(hash_including(:target_platform => "twitter"))
      
      post "query", :json_data => @api_call_params.to_json

      @api_call_params["platform"] = "facebook"
      @share_message_handler.should_receive(:get_message_for).with(hash_including(:target_platform => "facebook"))
      
      post "query", :json_data => @api_call_params.to_json
    end
    
    it "should take into account that we're sharing a book" do
      @share_message_handler.should_receive(:get_message_for).with(hash_including(:message_type => "book share"))
      
      post "query", :json_data => @api_call_params.to_json
    end
    
    # TODO: could have a better test
    it "should have a proper response for Twitter" do
      post "query", :json_data => @api_call_params.to_json
    
      parsed_response = ActiveSupport::JSON.decode(response.body)
      
      parsed_response.class.should == String
      parsed_response.should_not be_blank
    end
    
    it "should have a proper response for Facebook" do
      @api_call_params["platform"] = "facebook"
      post "query", :json_data => @api_call_params.to_json
    
      parsed_response = ActiveSupport::JSON.decode(response.body)
      
      parsed_response.class.should == Hash
      parsed_response.keys.sort.should == ["cover_url", "description", "link", "title"]
    end
    
  end
  
  describe "getting the share message for a selected text from a book" do
    
    before(:each) do
      @api_call_params = {
        "book_id"         => @book.id,
        "action"          => "get_tweet_and_facebook_share_texts",
        "platform"        => "twitter",
        "message_type"    => "selected text share"
      }
      
      @share_message_handler = ShareMessageHandler.new
      ShareMessageHandler.stub!(:new).and_return(@share_message_handler)
    end
    
    it "should take into account the platform" do
      @api_call_params["platform"] = "twitter"
      @share_message_handler.should_receive(:get_message_for).with(hash_including(:target_platform => "twitter"))
      
      post "query", :json_data => @api_call_params.to_json
    end
    
    it "should take into account that we're sharing a selected text" do
      @share_message_handler.should_receive(:get_message_for).with(hash_including(:message_type => "selected text share"))
      
      post "query", :json_data => @api_call_params.to_json
    end
    
    # TODO: could have a better test
    it "should have a proper response for Twitter" do
      post "query", :json_data => @api_call_params.to_json
    
      parsed_response = ActiveSupport::JSON.decode(response.body)
      
      parsed_response.class.should == String
      parsed_response.should_not be_blank
    end
    
  end    
  
end