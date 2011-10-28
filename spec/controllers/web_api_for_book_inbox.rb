describe WebApiController, "(API calls - book inbox related)" do
  
  describe "sending a book to another user" do
    
    before(:each) do
      @source_user      = FactoryGirl.create(:login, :fb_connect_id => "123", :first_name => "Source", :email => "source@test.com")
      @destination_user = FactoryGirl.create(:login, :fb_connect_id => "234", :first_name => "Destination", :email => "destination@test.com")
      
      @data = {
        "structure_version"      => "1.4",
        "source_user_email"      => @source_user.email,
        "destination_user_email" => @destination_user.email 
        "action"                 => "send_book_from_user_to_user",
        "book_type"              => "classic",
        "book_id"                => @book.id,
        "book_data"              => nil,
        "timestamp"              => (Time.now).to_s(:db)
      }
    end
    
    it "should create a book delivery package" do
      post("create",
          :json_data     => @data.to_json,
          :api_key       => APP_CONFIG["api_key"],
          :api_signature => Digest::MD5.hexdigest(@data.to_json + APP_CONFIG["api_secret"])
        )
      
      BookDeliveryPackage.should have(1).record
    end
    
  end
  
  describe "receiving a book from another user" do
    
    it "should show up in the user's inbox"
    
    it "should be acceptable"
    
    it "should be rejectable"
    
  end
  
  describe "accepting a sent book"
  
  describe "rejecting a sent book"
  
end