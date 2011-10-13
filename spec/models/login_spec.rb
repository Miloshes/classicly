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
      
      @login = stub_model(Login, :fb_connect_id => "123")
      
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
    
    it "should convert all the anonymous reviews of the user into normal ones" do
      @login.should_receive(:convert_anonymous_reviews_into_normal_ones)
      
      Login.register_from_ios_app(@api_call_params)
    end
    
    it "should convert all the anonymous book highlights & notes of the user into normal ones" do
      @login.should_receive(:convert_anonymous_book_highlights_into_normal_ones)
      
      Login.register_from_ios_app(@api_call_params)
    end
    
    describe "keeping track of the devices of the user" do
      it "should make sure the device is registered and assigned to the right user" do
        IosDevice.should_receive(:make_sure_its_registered_and_assigned_to_user)
        
        Login.register_from_ios_app(@api_call_params)
      end

      it "should migrate the device UDIDs" do
        IosDevice.should_receive(:try_to_migrate_device_udids)

        Login.register_from_ios_app(@api_call_params)
      end
    end
    
    describe "getting turned into a full-blown Classicly account" do

      before(:each) do
        new_api_call_params = {
          "structure_version" => "1.3",
          "twitter_name"      => "zsolt_maslanyi",
          "password"          => "pass123",
          "terms_of_services" => "accepted"
        }
      end

      it "should have a password"

      it "should have terms of services accepted"

      it "should have a twitter name attribute"

    end
    
  end
  
end