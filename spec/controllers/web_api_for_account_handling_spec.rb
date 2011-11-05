describe WebApiController, "(API calls - account handling related)" do
  
  describe "keeping compatibility with the old registration system" do
    
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
  
    it "should be able to register an iOS user" do
      post "create", :json_data => @data.to_json
    
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
    
    it "should use the Facebook ID as the main means of retrieving a user" do
      Login.should_receive(:where).with(hash_including(:fb_connect_id)).and_return([])
      
      post "create", :json_data => @data.to_json
    end
  
  end
  
  describe "a classicly account" do
    
    before(:each) do
      @data = {
          "structure_version"     => "1.3",
          "action"                => "register_ios_user",
          "user_fbconnect_id"     => "1232134",
          "device_ss_id"          => "ASDASD",
          "user_email"            => "test@test.com",
          "user_first_name"       => "Zsolt",
          "user_last_name"        => "Maslanyi",
          "user_location_city"    => "Budapest",
          "user_location_country" => "Hungary",
          # new params for the 1.3 api
          "twitter_name"          => "zsolt_maslanyi",
          "password"              => "pass123",
          "terms_of_service"      => "accepted"
        }
      
    end
    
    describe "when getting created" do
      
      it "should be able to register a new Classicly account for an iOS user" do
        post("create",
            :json_data     => @data.to_json,
            :api_key       => APP_CONFIG["api_key"],
            :api_signature => Digest::MD5.hexdigest(@data.to_json + APP_CONFIG["api_secret"])
          )
        
        Login.should have(1).record
      end
      
      it "should respond with the account's data for a successfull registration" do
        post("create",
            :json_data     => @data.to_json,
            :api_key       => APP_CONFIG["api_key"],
            :api_signature => Digest::MD5.hexdigest(@data.to_json + APP_CONFIG["api_secret"])
          )
        
        parsed_response = ActiveSupport::JSON.decode(response.body)
        
        parsed_response.class.should == Hash
        parsed_response.keys.sort.should == %w(email fb_connect_id first_name general_response last_name location_city location_country twitter_name)
      end
      
      it "should respond with failure when trying to register an existing account" do
        # we have an account that's fully registered
        login = mock_model(Login, :not_a_real_account => false)
        Login.stub_chain(:where, :first).and_return(login)
        
        post("create",
            :json_data     => @data.to_json,
            :api_key       => APP_CONFIG["api_key"],
            :api_signature => Digest::MD5.hexdigest(@data.to_json + APP_CONFIG["api_secret"])
          )
        
        parsed_response = ActiveSupport::JSON.decode(response.body)
        
        parsed_response.should == {"general_response" => "FAILURE"}
      end
      
      it "should migrate half-accounts" do
        login = FactoryGirl.create(:login, :fb_connect_id => "123", :first_name => "Zsolt", :email => "email_to_check@test.com")
        Login.stub_chain(:where, :first).and_return(login)
  
        post("create",
            :json_data     => @data.to_json,
            :api_key       => APP_CONFIG["api_key"],
            :api_signature => Digest::MD5.hexdigest(@data.to_json + APP_CONFIG["api_secret"])
          )
        
        login.not_a_real_account.should == false
      end
      
      it "should use the user email as the main means of retrieving a user" do
        Login.should_receive(:where).with(hash_including(:email)).and_return([])

        post("create",
          :json_data     => @data.to_json,
          :api_key       => APP_CONFIG["api_key"],
          :api_signature => Digest::MD5.hexdigest(@data.to_json + APP_CONFIG["api_secret"])
        )
      end
      
    end
    
    describe "doing authentication" do
      
      before(:each) do
        @login = FactoryGirl.create(:login, :email => "test@test.com", :password => "pass123")
        Login.stub_chain(:where, :first).and_return(@login)
      
        @data = {
          "structure_version"     => "1.3",
          "action"                => "login_ios_user",
          "user_email"            => "test@test.com",
          "password"              => "pass123"
        }
      end
    
      it "should respond with the user data for a successfull login" do
      
        # Trying success
        post("create",
            :json_data     => @data.to_json,
            :api_key       => APP_CONFIG["api_key"],
            :api_signature => Digest::MD5.hexdigest(@data.to_json + APP_CONFIG["api_secret"])
          )

        parsed_response = ActiveSupport::JSON.decode(response.body)
        
        parsed_response.class.should == Hash
        parsed_response.keys.sort.should == %w(email fb_connect_id first_name general_response last_name location_city location_country twitter_name)
      end
    
      it "should respond with failure for a login attempt with a bad password" do
        # Trying failure - bad password
        @data["password"] = "wrong password"

        post("create",
            :json_data     => @data.to_json,
            :api_key       => APP_CONFIG["api_key"],
            :api_signature => Digest::MD5.hexdigest(@data.to_json + APP_CONFIG["api_secret"])
          )
        
        parsed_response = ActiveSupport::JSON.decode(response.body)
        parsed_response.should == {"general_response" => "FAILURE"}
      end
      
    end
    
    # TODO: later
    # it "should have a reset password functionality"
    
    describe "querying information about a user" do
    
      it "should be able to give information about a user" do
        login = FactoryGirl.create(:login, :fb_connect_id => "123", :first_name => "Zsolt", :email => "email_to_check@test.com")
    
        data = {
            "structure_version" => "1.3",
            "action"            => "get_user_data",
            "user_fbconnect_id" => "123"
          }
    
        post("query",
            :json_data     => data.to_json,
            :api_key       => APP_CONFIG["api_key"],
            :api_signature => Digest::MD5.hexdigest(data.to_json + APP_CONFIG["api_secret"])
          )
    
        parsed_response = ActiveSupport::JSON.decode(response.body)
    
        parsed_response["email"].should == "email_to_check@test.com"
        parsed_response["first_name"].should == "Zsolt"
      end
      
      it "shouldn't give out sensitive information" do
        login = FactoryGirl.create(:login, :fb_connect_id => "123", :first_name => "Zsolt", :email => "email_to_check@test.com")
    
        data = {
            "structure_version" => "1.3",
            "action"            => "get_user_data",
            "user_fbconnect_id" => "123"
          }
    
        post("query",
            :json_data     => data.to_json,
            :api_key       => APP_CONFIG["api_key"],
            :api_signature => Digest::MD5.hexdigest(data.to_json + APP_CONFIG["api_secret"])
          )
    
        parsed_response = ActiveSupport::JSON.decode(response.body)

        ["hashed_password", "salt", "access_token", "is_admin", "mailing_enabled"].each do |prohibited_field|
          parsed_response.should_not include(prohibited_field)
        end
      end

    end
    
  end

end