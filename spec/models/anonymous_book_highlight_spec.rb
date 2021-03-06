require 'spec_helper'

describe AnonymousBookHighlight do
  
  before(:each) do
    @author     = mock_model(Author, :name => "Victor Hugo", :cached_slug => "victor-hugo")
    @book       = mock_model(Book, :author => @author, :pretty_title => "Les miserables", :cached_slug => "les-miserables")
    @ios_device = mock_model(IosDevice, :original_udid => "original_udid1", :ss_udid => "ss_udid1")
    @login      = mock_model(Login, :fb_connect_id => "123", :ios_device => @ios_device)

    @book.stub!(:pretty_download_formats).and_return(["PDF", "Kindle", "Rtf"])
    Login.stub_chain(:where, :first).and_return(@login)
    @ios_device.stub!(:user).and_return(@login)
    IosDevice.stub!(:find_by_ss_udid).and_return(@ios_device)
    IosDevice.stub!(:find_by_original_udid).and_return(@ios_device)

    @book_highlight = AnonymousBookHighlight.new(
      :first_character  => 0,
      :last_character   => 9,
      :content          => "content 12",
      :book             => @book,
      :ios_device_id    => @login.ios_device.original_udid,
      :ios_device_ss_id => @login.ios_device.ss_udid,
      :created_at       => Time.now,
      :cached_slug      => "content-12"
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
      
      @book_highlight.last_character = 9

      @book_highlight.content = nil
      @book_highlight.should_not be_valid
    end
    
    it "should have a book assigned to it" do
      @book_highlight.book = nil
      @book_highlight.should_not be_valid
    end
    
    it "should have an ios_device_ss_id assigned to it" do
      @book_highlight.ios_device_ss_id = nil
      @book_highlight.should_not be_valid
    end
  end
  
  describe "getting created via a Web API call" do
    
    before(:each) do
      @api_call_params = {
        "device_ss_id"    => @login.ios_device.ss_udid,
        "book_id"         => @book.id,
        "action"          => "register_book_highlight",
        "first_character" => 0,
        "last_character"  => 29,
        "content"         => "The rabbit went down the hole.",
        "origin_comment"  => "here's my comment",
        "timestamp"       => (Time.now).to_s(:db)
      }
      
      Book.should_receive(:find).with(@api_call_params["book_id"]).and_return(@book)
    end
    
    it "should fail when one of the required parameters is missing from the API call parameters" do
      Book.stub(:find).and_return(nil)
      
      %w{first_character last_character book_id device_id}.each do |parameter_to_cut|
        api_params = @api_call_params.clone
        api_params.delete(parameter_to_cut)
        
        expect {
          AnonymousBookHighlight.create_or_update_from_ios_client_data(api_params)
        }.to_not change(AnonymousBookHighlight, :count)
      end
    end
    
    it "should create a new highlight if there's no highlight" do
      # the highlight doesn't exists
      AnonymousBookHighlight.stub_chain(:where, :first).and_return(nil)
      
      expect {
        AnonymousBookHighlight.create_or_update_from_ios_client_data(@api_call_params)
      }.to change(AnonymousBookHighlight, :count).by(1)
    end
    
    it "should update the existing highlight if there's already one" do
      # future timestamp, so the update actually happens
      new_timestamp = (Time.now + 10.minutes).to_s(:db)
      @api_call_params["timestamp"] = new_timestamp
      # the change of data
      @api_call_params["origin_comment"] = "changed comment"
      # the highlight exists
      AnonymousBookHighlight.stub_chain(:where, :first).and_return(@book_highlight)
      # a call to update_attributes should be made
      @book_highlight.should_receive(:update_attributes).with(hash_including(:origin_comment => "changed comment"))
      
      AnonymousBookHighlight.create_or_update_from_ios_client_data(@api_call_params)
    end
    
    # test outdated update request, a call that got stuck in the ether
    it "should not update the existing highlight if the update's timestamp is actually less then the exiting one's" do
      # the highlight exists
      AnonymousBookHighlight.stub_chain(:where, :first).and_return(@book_highlight)
      # the timestamp points to a past point
      @api_call_params["timestamp"] = (Time.now - 10.minutes).to_s(:db)
      # the change of data
      @api_call_params["origin_comment"] = "changed comment"
      # a call to update_attributes should NOT be made
      @book_highlight.should_not_receive(:update_attributes)
      
      AnonymousBookHighlight.create_or_update_from_ios_client_data(@api_call_params)
    end
    
    it "should have a public URL" do
      new_highlight = AnonymousBookHighlight.create_or_update_from_ios_client_data(@api_call_params)
      
      new_highlight.should respond_to(:public_url)
      new_highlight.public_url.should include("http://www.classicly.com/")
    end
  end
  
  describe "being converted into normal highlights" do
    
    before(:each) do
      @book  = FactoryGirl.create(:book)
      
      @highlight  = FactoryGirl.create(:anonymous_book_highlight,
          :book             => @book,
          :ios_device_ss_id => @login.ios_device.ss_udid,
          :first_character  => 0,
          :last_character   => 6,
          :content          => "content"
        )
      @highlight2 = FactoryGirl.create(:anonymous_book_highlight_with_note,
          :book => @book,
          :ios_device_ss_id => @login.ios_device.ss_udid
        )
    end
    
    it "should convert all the highlights for the book and user" do
      AnonymousBookHighlight.all_for_book_and_ios_device(@book, @login.ios_device.ss_udid).each do |abh|
        abh.convert_to_normal_highlight
      end

      AnonymousBookHighlight.all_for_book_and_ios_device(@book, @login.ios_device.ss_udid).count.should == 0
    end
    
    it "should correctly assign the new highlights to the user" do
      AnonymousBookHighlight.all_for_book_and_ios_device(@book, @login.ios_device.ss_udid).each do |abh|
        abh.convert_to_normal_highlight
      end
      
      BookHighlight.all_for_book_and_user(@book, @login).count.should == 2
    end
    
  end
  
end
