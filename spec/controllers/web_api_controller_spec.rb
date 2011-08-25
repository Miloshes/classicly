require 'spec_helper'

# Testing the Web API

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
  
  it "should be able to register a book review" do
    book = mock_model(Book)
    Book.stub!(:find).and_return(book)

    login = mock_model(Login, :fb_connect_id => "123")
    Login.stub_chain(:where, :first).and_return(login)
    
    data = {
        "user_fbconnect_id" => login.fb_connect_id,
        "device_id"         => "ASDASD",
        "book_id"           => book.id,
        "action"            => "register_book_review",
        "content"           => "I just can't put it down. Spent the last 2 weeks reading it, can't wait to finish and read the sequel.2",
        "rating"            => 5,
        "timestamp"         => "Thu Feb 10 15:09:59 +0100 2011"
      }
      
      post "create", :json_data => data.to_json

      response.body.should == "SUCCESS"
      Review.should have(1).record
  end

end
