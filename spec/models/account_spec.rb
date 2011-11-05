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
    end
    
    it "should fail when one of the required parameters is missing from the API call parameters" do
      %w{structure_version user_fbconnect_id}.each do |parameter_to_cut|
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
      Login.stub_chain(:where, :first).and_return(@login)
      @login.should_receive(:convert_anonymous_reviews_into_normal_ones)
      
      Login.register_from_ios_app(@api_call_params)
    end

    # NOTE: we're disabling this until we have Terms of Service in place and such
    # it "should convert all the anonymous book highlights & notes of the user into normal ones" do
    #   Login.stub_chain(:where, :first).and_return(@login)
    #   @login.should_receive(:convert_anonymous_book_highlights_into_normal_ones)
    #   
    #   Login.register_from_ios_app(@api_call_params)
    # end
    
    describe "keeping track of the devices of the user" do
      it "should make sure the device is registered and assigned to the right user" do
        Login.stub_chain(:where, :first).and_return(nil)
        IosDevice.should_receive(:make_sure_its_registered_and_assigned_to_user)
        
        Login.register_from_ios_app(@api_call_params)
      end

      it "should migrate the device UDIDs" do
        Login.stub_chain(:where, :first).and_return(nil)
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
          "terms_of_service"  => "accepted"
        }
        
        @api_call_params.merge!(new_api_call_params)
        
        # the login doesn't exists
        Login.stub_chain(:where, :first).and_return(nil)
      end

      it "should have a password" do
        login = Login.register_from_ios_app(@api_call_params)
        
        login.password.should_not be_blank
      end

      it "should have 'terms of service' accepted" do
        login = Login.register_from_ios_app(@api_call_params)
        
        login.terms_of_service.should_not be_blank
      end
      
      it "should be able to tell if it's a full account or not" do
        new_login = Login.register_from_ios_app(@api_call_params)
        
        new_login.not_a_real_account.should == false
      end

    end
    
  end
  
  describe "handling passwords" do
    
    it "should store the password hash and the salt in the database" do
      login = Login.create(:password => "123")
      
      login.read_attribute("hashed_password").should_not be_blank
      login.read_attribute("salt").should_not be_blank
    end
    
    it "should update the hash and the salt on a password change" do
      login = Login.new
      
      expect {
        login.password = "new password"
      }.to (change(login, :hashed_password) && change(login, :salt))
    end
    
    it "can authenticate Users" do
      login = Login.create(:email => "test@email.com", :password => "123")
      
      Login.authenticate("test@email.com", "123").should == login
    end
    
  end
  
end