require 'spec_helper'

describe BookHighlight do
  
  before(:each) do
    @author = mock_model(Author, :name => "Victor Hugo", :cached_slug => "victor-hugo")
    @book   = mock_model(Book, :author => @author, :pretty_title => "Les miserables", :cached_slug => "les-miserables")
    @login  = mock_model(Login, :fb_connect_id => "123", :ios_device_id => "asd")

    Login.stub_chain(:where, :first).and_return(@login)

    @book_highlight = BookHighlight.new(
      :first_character => 0,
      :last_character  => 9,
      :content         => "content 12",
      :book            => @book,
      :user            => @login,
      :fb_connect_id   => @login.fb_connect_id,
      :created_at      => Time.now,
      :cached_slug     => "content-12"
    )
  end
  
  context "when getting created" do
    it "should have the first_character, last_character and content attributes set" do
      @book_highlight.should be_valid
      
      @book_highlight.first_character = nil
      @book_highlight.should_not be_valid
      
      @book_highlight.first_character = 1
      
      @book_highlight.last_character = nil
      @book_highlight.should_not be_valid
      
      @book_highlight.last_character = 9
      
      @book_highlight.content = nil
      @book_highlight.should_not be_valid
    end
    
    it "should have a book assigned to it" do
      @book_highlight.book = nil
      @book_highlight.should_not be_valid
    end
    
    it "should have a registered user assigned to it" do
      @book_highlight.user = nil
      @book_highlight.should_not be_valid
      
      @book_highlight.user = @login
      
      @book_highlight.fb_connect_id = nil
      @book_highlight.should_not be_valid
    end
  end
  
  describe "getting created via a Web API call" do
    
    before(:each) do
      @api_call_params = {
        "device_id"         => @login.ios_device_id,
        "user_fbconnect_id" => @login.fb_connect_id,
        "book_id"           => @book.id,
        "action"            => "register_book_highlight",
        "first_character"   => 0,
        "last_character"    => 29,
        "content"           => "The rabbit went down the hole.",
        "origin_comment"    => "here's my comment",
        "timestamp"         => (Time.now).to_s(:db)
      }
      
      Book.should_receive(:find).with(@api_call_params["book_id"]).any_number_of_times.and_return(@book)
    end
    
    it "should fail when one of the required parameters is missing from the API call parameters" do
      Book.stub(:find).and_return(nil)
      
      %w{first_character last_character book_id device_id user_fbconnect_id content}.each do |parameter_to_cut|
        api_params = @api_call_params.clone
        api_params.delete(parameter_to_cut)
        
        expect {
          BookHighlight.create_or_update_from_ios_client_data(api_params)
        }.to_not change(BookHighlight, :count)
      end
    end
    
    it "should create a new highlight if there's no highlight" do
      # the highlight doesn't exists
      BookHighlight.stub_chain(:where, :first).and_return(nil)
      
      expect {
        BookHighlight.create_or_update_from_ios_client_data(@api_call_params)
      }.to change(BookHighlight, :count).by(1)
    end
    
    it "should create an anonymous highlight instead if by some mistake the user is not registered yet" do
      # faking that the user doesn't exist
      Login.stub_chain(:where, :first).and_return(nil)
      
      BookHighlight.create_or_update_from_ios_client_data(@api_call_params)
      
      AnonymousBookHighlight.should have(1).record
      BookHighlight.should have(0).records
    end
    
    it "should update the existing highlight if there's already one" do
      # future timestamp, so the update actually happens
      new_timestamp = (Time.now + 10.minutes).to_s(:db)
      @api_call_params["timestamp"] = new_timestamp
      # the change of data
      @api_call_params["origin_comment"] = "changed comment"
      # the highlight exists
      BookHighlight.stub_chain(:where, :first).and_return(@book_highlight)
      # a call to update_attributes should be made
      @book_highlight.should_receive(:update_attributes).with(hash_including(:origin_comment => "changed comment"))
      
      BookHighlight.create_or_update_from_ios_client_data(@api_call_params)
    end
    
    # test outdated update request, a call that got stuck in the ether
    it "should not update the existing highlight if the update's timestamp is actually less then the exiting one's" do
      # the highlight exists
      BookHighlight.stub_chain(:where, :first).and_return(@book_highlight)
      # the timestamp points to a past point
      @api_call_params["timestamp"] = (Time.now - 10.minutes).to_s(:db)
      # the change of data
      @api_call_params["origin_comment"] = "changed comment"
      # a call to update_attributes should NOT be made
      @book_highlight.should_not_receive(:update_attributes)
      
      BookHighlight.create_or_update_from_ios_client_data(@api_call_params)
    end
    
    it "should have a public URL" do
      new_highlight = BookHighlight.create_or_update_from_ios_client_data(@api_call_params)
      
      new_highlight.should respond_to(:public_url)
      new_highlight.public_url.should include("http://www.classicly.com/")
    end
  end
  
end
