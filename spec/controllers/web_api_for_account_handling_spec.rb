describe WebApiController, "(API calls - account handling related)" do
  
  describe "keeping compatibility with the old registration system" do
  
    it "should be able to register an iOS user" do
      data = {
          "structure_version"     => "1.2",
          "action"                => "register_ios_user",
          "user_fbconnect_id"     => "1232134",
          "device_ss_id"          => "ASDASD",
          "user_email"            => "test@test.com",
          "user_first_name"       => "Zsolt",
          "user_last_name"        => "Maslanyi",
          "user_location_city"    => "Budapest",
          "user_location_country" => "Hungary"
        }
    
      post "create", :json_data => data.to_json
    
      Login.should have(1).record
    end
  
    it "should be able to give information about a user" do
      login = FactoryGirl.create(:login, :fb_connect_id => "123", :first_name => "Zsolt", :email => "email_to_check@test.com")
    
      data = {
          "action"            => "get_user_data",
          "user_fbconnect_id" => "123"
        }
    
      post "query", :json_data => data.to_json
    
      parsed_response = ActiveSupport::JSON.decode(response.body)
    
      parsed_response["email"].should == "email_to_check@test.com"
      parsed_response["first_name"].should == "Zsolt"
    end
  
  end
  
  describe "registering a classicly account" do
    
    before(:each) do
      @data = {
          "structure_version"     => "1.2",
          "action"                => "register_ios_user",
          "user_fbconnect_id"     => "1232134",
          "device_ss_id"          => "ASDASD",
          "user_email"            => "test@test.com",
          "user_first_name"       => "Zsolt",
          "user_last_name"        => "Maslanyi",
          "user_location_city"    => "Budapest",
          "user_location_country" => "Hungary"
        }
      
    end
    
  end
  
  describe "updating a classicly account"
  
  describe "logging in - "

end