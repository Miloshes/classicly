require "spec_helper"

describe Login do
  
  describe "getting created via a Web API call" do
    before(:each) do
      @api_call_params = {
          "structure_version"     => "1.2",
          "action"                => "register_ios_user",
          "user_fbconnect_id"     => "1232134",
          "device_id"             => "asd",
          "device_ss_id"          => "asd2",
          "user_email"            => "test@test.com",
          "user_first_name"       => "Zsolt",
          "user_last_name"        => "Maslanyi",
          "user_location_city"    => "Budapest",
          "user_location_country" => "Hungary"
        }
      
      @login = mock_model(Login, :fb_connect_id => "123", :ios_device_id => "asd", :ios_device_ss_id => "asd2")
      @login.stub!(:convert_anonymous_reviews_into_normal_ones)
      @login.stub!(:convert_anonymous_book_highlights_into_normal_ones)
      
      Login.stub_chain(:where, :first).and_return(@login)
    end
    
    it "should fail when one of the required parameters is missing from the API call parameters" do
      %w{action structure_version user_fbconnect_id}.each do |parameter_to_cut|
        api_params = @api_call_params.clone
        api_params.delete(parameter_to_cut)
        
        expect {
          Login.register_from_ios_app(api_params)
        }.to_not change(Login, :count)
      end
    end
    
    it "should create a new login if there's no login" do
      # the login doesn't exists
      Login.stub_chain(:where, :first).and_return(nil)
      
      expect {
        Login.register_from_ios_app(@api_call_params)
      }.to change(Login, :count).by(1)
    end
    
    it "should register the ss_device_id when the login exists but doesn't have it already" do
      @login.stub!(:ios_device_ss_id).and_return(nil)
      
      @login.should_receive(:update_attributes).with(hash_including(:ios_device_ss_id => @api_call_params["device_ss_id"]))
      
      Login.register_from_ios_app(@api_call_params)
    end
    
    it "should convert all the anonymous reviews of the user into normal ones" do
      @login.should_receive(:convert_anonymous_reviews_into_normal_ones)
      
      Login.register_from_ios_app(@api_call_params)
    end
    
    it "should convert all the anonymous book highlights & notes of the user into normal ones" do
      @login.should_receive(:convert_anonymous_book_highlights_into_normal_ones)
      
      Login.register_from_ios_app(@api_call_params)
    end
    
  end
  
end