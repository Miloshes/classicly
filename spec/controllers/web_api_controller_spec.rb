require "spec_helper"

# Testing the Web API
# TODO: test structure version differences between 1.1 and 1.2

describe WebApiController do

  describe "serving an API call" do
    
    it "should return nothing when called without parameters and data" do
      post "create"
      response.should be_success
      response.body.should == "FAILURE"
    end
    
    it "should process incoming data using the WebApiHandler" do      
      handler = mock(WebApiHandler)

      WebApiHandler.should_receive(:new).and_return(handler)
      handler.should_receive(:handle_incoming_data)
      
      post "create"
    end
  end
  
  describe "authenticating an API call" do
    
    context "when the API version is less than 1.3" do
      
      it "is not needed" do
        data = {"structure_version" => "1.2"}

        post("create", :json_data => data.to_json)

        response.should be_success
      end
      
    end
    
    context "when the API version is greater or equal than 1.3" do
      it "should have an api_key and api_signature in the parameters" do
        data = {"structure_version" => "1.3"}
        
        base_api_params = {
          :json_data     => data.to_json,
          :api_key       => APP_CONFIG["api_key"],
          :api_signature => Digest::MD5.hexdigest(data.to_json + APP_CONFIG["api_secret"])
        }
        
        %w{api_key api_signature}.each do |parameter_to_cut|
          api_params = base_api_params.clone
          api_params.delete(parameter_to_cut.to_sym)

          post("create", api_params)
          
          response.status.should == 401
        end
      end
      
      it "should return HTTP 401 (unauthorized) for a wrong API key" do
        data = {"structure_version" => "1.3"}
        
        post("create",
            :json_data     => data.to_json,
            :api_key       => "wrong key",
            :api_signature => Digest::MD5.hexdigest(data.to_json + APP_CONFIG["api_secret"])
          )
        
        response.status.should == 401
      end
      
      it "should return HTTP 401 (unauthorized) for a wrong API signature" do
        data = {"structure_version" => "1.3"}
        
        post("create",
            :json_data     => data.to_json,
            :api_key       => APP_CONFIG["api_key"],
            :api_signature => "wrong signature"
          )
          
        response.status.should == 401
      end
      
      it "should return HTTP 200 on success" do
        data = {"structure_version" => "1.3"}
        
        post("create",
            :json_data     => data.to_json,
            :api_key       => APP_CONFIG["api_key"],
            :api_signature => Digest::MD5.hexdigest(data.to_json + APP_CONFIG["api_secret"])
          )
        
        response.should be_success
      end
    end
    
  end
     
  describe "answering queries" do
    it "should process the query using the WebApiHandler and return the results" do
      handler = mock(WebApiHandler)

      WebApiHandler.should_receive(:new).and_return(handler)
      handler.should_receive(:process_query)

      post "query"
      
      response.should be_success
    end
  end
  
  describe "having a good routes setup" do
    
    it "should map POST /web_api calls to the create action" do
      {:post => "web_api"}.should route_to(:controller => "web_api", :action => "create")
    end
    
    it "should map POST /web_api/query calls to the query action" do
      {:post => "web_api/query"}.should route_to(:controller => "web_api", :action => "query")
    end
    
  end
end
