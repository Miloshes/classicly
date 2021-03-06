require "spec_helper"

# TODO: properly test registration through classicly.com

describe Login do
  
  before(:each) do
    @login = stub_model(
        Login,
        :fb_connect_id   => "123",
        :email           => "test@test.com",
        :user_first_name => "Zsolt",
        :user_last_name  => "Maslanyi"
      )
      
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
  end
  
  describe "getting created via a Web API call" do
    
    it "should fail when one of the required parameters is missing from the API call parameters" do
      # structure_version is not required as we want to support ancient versions of the API (1.0)
      %w{user_fbconnect_id}.each do |parameter_to_cut|
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
    
    it "should generate an unsubscribe access token" do
      new_login = Login.register_from_ios_app(@api_call_params)
      
      new_login.access_token.should_not be_blank
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

    context "when doing a password reset" do
      it "should have a password reset token along with a timestamp to mark it's validity" do
        login = Login.new

        expect {
          login.send_password_reset
        }.to (change(login, :password_reset_token) && change(login, :password_reset_sent_at))
      end

      it "should send out a password reset email" do
        login = Login.new

        mail_to_send = mock("LoginMailer")
        LoginMailer.should_receive(:password_reset).and_return(mail_to_send)
        mail_to_send.should_receive(:deliver)

        login.send_password_reset
      end
    end
    
  end
  
  describe "sending out registration welcome emails" do
    
    context "when the user registers from an iOS app" do
      
      it "should send out a welcome email to a new user" do
        Login.stub_chain(:where, :first).and_return(nil)
        mail_to_send = mock("LoginMailer")
        
        LoginMailer.should_receive(:registration_notification_for_ios).and_return(mail_to_send)
        mail_to_send.should_receive(:deliver)

        Login.register_from_ios_app(@api_call_params)
      end

      it "shouldn't send an email to existing users" do
        Login.stub_chain(:where, :first).and_return(@login)

        LoginMailer.should_not_receive(:registration_notification_for_ios)

        Login.register_from_ios_app(@api_call_params)
      end
      
    end
    
    context "when the user registers through classicly.com" do
      
      before(:each) do
        @user_profile_hash = {
          "email"      => @login.email,
          "first_name" => @login.first_name,
          "last_name"  => @login.last_name,
          "location"   => {}
        }
        
        @user_profile_hash["location"]["name"] = "Budapest, Hungary"
      end
      
      it "should send out a welcome email to a new user" do
        Login.stub_chain(:where, :first).and_return(nil)
        mail_to_send = mock("LoginMailer")
      
        LoginMailer.should_receive(:registration_notification_for_web).and_return(mail_to_send)
        mail_to_send.should_receive(:deliver)

        Login.register_from_classicly(@user_profile_hash)
      end

      it "shouldn't send an email to existing users" do
        Login.stub(:exists?).and_return(true)
      
        LoginMailer.should_not_receive(:registration_notification_for_web)

        Login.register_from_classicly(@user_profile_hash)
      end
      
    end
    
  end
  
  describe "looking up a user account" do
    
    it "should find an account based on the email address" do
      user_to_find = FactoryGirl.create(:login, :email => "email@test.com")
      
      found_user = Login.find_user("email@test.com")
      
      found_user.should == user_to_find
    end
    
    it "should find an account based on the Facebook ID" do
      user_to_find = FactoryGirl.create(:login, :fb_connect_id => "123456")
      
      found_user = Login.find_user(nil, "123456")
      
      found_user.should == user_to_find
    end
    
    it "should find an account based on the device ID" do
      user_to_find = FactoryGirl.create(:login)
      ios_device = FactoryGirl.create(:ios_device, :user => user_to_find)
      
      found_user = Login.find_user(nil, nil, ios_device.ss_udid)
      
      found_user.should == user_to_find
    end
    
    it "should have a lookup order of email, Facebook ID, device ID" do
      # set up the expectations, but no user in the system
      Login.should_receive(:find_by_email).ordered
      Login.should_receive(:find_by_fb_connect_id).ordered
      Login.should_receive(:find_user_by_device).ordered
      
      user_to_find = Login.find_user("no_email_like_this", "no_fb_like_this", "no_device_like_this")
      
      # shouldn't find anyone
      user_to_find.should be_nil
    end
    
  end
  
  
end