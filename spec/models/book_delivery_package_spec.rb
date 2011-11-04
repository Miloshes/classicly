require 'spec_helper'

describe BookDeliveryPackage do
  
  before(:each) do
    @author      = mock_model(Author, :name => "Victor Hugo", :cached_slug => "victor-hugo")
    @book        = mock_model(Book, :author => @author, :pretty_title => "Les miserables", :cached_slug => "les-miserables")
    @ios_device  = mock_model(IosDevice, :original_udid => "original_udid1", :ss_udid => "ss_udid1")
    @ios_device2 = mock_model(IosDevice, :original_udid => "original_udid2", :ss_udid => "ss_udid2")

    @source_user      = FactoryGirl.create(:login, :first_name => "Source")
    @destination_user = FactoryGirl.create(:login, :first_name => "Destination")
    
    @source_user.stub!(:ios_device).and_return(@ios_device)
    @destination_user.stub!(:ios_device).and_return(@ios_device2)

    @book_delivery_package = BookDeliveryPackage.new(
      :source_user      => @source_user,
      :destination_user => @destination_user,
      :deliverable      => @book
    )
  end
  
  context "when getting created" do
    it "should have the source_user and destination_user attributes set" do
      @book_delivery_package.should be_valid
      
      @book_delivery_package.source_user = nil
      @book_delivery_package.should_not be_valid
      
      @book_delivery_package.source_user = @login
      
      @book_delivery_package.destination_user = nil
      @book_delivery_package.should_not be_valid
    end
    
    it "should have a deliverable assigned to it" do
      @book_delivery_package.deliverable = nil
      @book_delivery_package.should_not be_valid
    end
  end
  
  describe "getting created via a Web API call" do
    
    before(:each) do
      @api_call_params = {
        "structure_version"      => "1.4",
        "source_user_email"      => @source_user.email,
        "destination_user_email" => @destination_user.email,
        "action"                 => "send_book_from_user_to_user",
        "book_type"              => "classic",
        "book_id"                => @book.id,
        "message"                => "You should read this",
        "book_data"              => nil,
        "timestamp"              => (Time.now).to_s(:db)
      }
    end
    
    context "when the deliverable is a classic book" do
      
      before(:each) do
        Book.should_receive(:find_by_id).with(@api_call_params["book_id"]).any_number_of_times.and_return(@book)
      end
      
      it "should fail when one of the required parameters is missing from the API call parameters" do
        @api_call_params["book_type"] = "classic"
        
        %w{source_user_email destination_user_email structure_version book_type book_id}.each do |parameter_to_cut|
          api_params = @api_call_params.clone
          api_params.delete(parameter_to_cut)
        
          expect {
            BookDeliveryPackage.create_from_web_api_call(api_params)
          }.to_not change(BookDeliveryPackage, :count)
        end
      end
      
      # sending a book more than once is ok, but have to wait until it gets delivered
      it "should create a book delivery package if there's no package like that" do
        # the package doesn't exists
        BookDeliveryPackage.stub_chain(:where, :first).and_return(nil)
      
        expect {
          BookDeliveryPackage.create_from_web_api_call(@api_call_params)
        }.to change(BookDeliveryPackage, :count).by(1)
      end
      
    end
    
    # context "when the deliverable is a user uploaded book" do
    #   
    #   it "should fail when one of the required parameters is missing from the API call parameters" do
    #     @api_call_params["book_type"] = "user_uploaded"
    #     
    #     %w{source_user_email destination_user_email structure_version book_type book_data}.each do |parameter_to_cut|
    #       api_params = @api_call_params.clone
    #       api_params.delete(parameter_to_cut)
    #     
    #       expect {
    #         BookDeliveryPackage.create_from_web_api_call(api_params)
    #       }.to_not change(BookDeliveryPackage, :count)
    #     end
    #   end
    # 
    #   it "should create a new highlight if there's no highlight" do
    #     # the highlight doesn't exists
    #     BookHighlight.stub_chain(:where, :first).and_return(nil)
    #   
    #     expect {
    #       BookDeliveryPackage.create_from_web_api_call(@api_call_params)
    #     }.to change(BookHighlight, :count).by(1)
    #   end
    # end
    
  end
  
  describe "getting accepted"
  
  describe "getting rejected"
  
  
end
