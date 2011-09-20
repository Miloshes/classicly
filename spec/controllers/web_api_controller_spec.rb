require "spec_helper"

# Testing the Web API
# TODO: test structure version differences between 1.1 and 1.2

describe WebApiController do

  context "serving an API call" do
    
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
  
  context "answering queries" do
    it "should process the query using the WebApiHandler and return the results" do
      handler = mock(WebApiHandler)

      WebApiHandler.should_receive(:new).and_return(handler)
      handler.should_receive(:process_query)

      post "query"
      
      response.should be_success
    end
  end
  
  context "having a good routes setup" do
    
    it "should map POST /web_api calls to the create action" do
      {:post => "web_api"}.should route_to(:controller => "web_api", :action => "create")
    end
    
    it "should map POST /web_api/query calls to the query action" do
      {:post => "web_api/query"}.should route_to(:controller => "web_api", :action => "query")
    end
    
  end
end
