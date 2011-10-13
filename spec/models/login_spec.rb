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

    it "should try to migrate to the new device UDID" do
      @login.should_receive(:try_to_migrate_device_udids).with(@api_call_params["device_id"], @api_call_params["device_ss_id"])
      
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
    
    describe "getting turned into a full-blown Classicly account" do

      before(:each) do
        new_api_call_params = {
          "structure_version" => "1.3",
          "twitter_name"      => "zsolt_maslanyi",
          "password"          => "pass123"
          "terms_of_services" => "accepted"
        }
      end

      it "should have a password"

      it "should have terms of services accepted"

      it "should have a twitter name attribute"

    end
    
    
  end
    
  describe "migrating device UDIDs" do
    
    before(:each) do
      @login = Login.new
    end
    
    context "when the old UDIDs is not available" do
      it "shouldn't do anything" do
        result = @login.try_to_migrate_device_udids(nil, "new_ss_id")
        
        result.should be_nil
      end
    end
    
    context "when the new UDID is not available" do
      it "shouldn't do anything" do
        result = @login.try_to_migrate_device_udids("original_udid", nil)
        
        result.should be_nil
      end
    end
    
    # NOTE: should figure out how to mock/stub the login.ios_devices.where.first call
    # This is tied to implementation too much
    context "when both UDIDs are available" do
      
      before(:each) do
        @ios_devices = mock("ios_devices")
        @login.should_receive(:ios_devices).and_return(@ios_devices)
      end
      
      it "should find the right device" do
        # should be something like IosDevice.should_receive(:where).with(hash_including(:original_udid)
        @ios_devices.should_receive(:where).with(hash_including(:original_udid)).and_return([])
        
        @login.try_to_migrate_device_udids("original_udid", "new_ss_id")
      end
      
      it "should store the new UDID" do
        ios_device = mock("ios_device")
        @ios_devices.stub_chain(:where, :first).and_return(ios_device)
        
        # should be something like IosDevice.any_instance.should_receive(:update_attributes).with(hash_including(:ss_udid))
        ios_device.should_receive(:update_attributes).with(hash_including(:ss_udid))
        @login.try_to_migrate_device_udids("original_udid", "new_ss_id")
      end
    end
    
  end
  
end