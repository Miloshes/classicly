require "spec_helper"

describe WebApiController, "(API calls - classicly.com related)" do
  
  it "should be able to get the classicly.com URL for a book" do
    book = FactoryGirl.create(:book)
    
    data = {
        "action"  => "get_classicly_url_for_book",
        "book_id" => book.id
      }
      
    post "query", :json_data => data.to_json
    
    response.body.should include("http://www.classicly.com")
  end
  
  it "should be able to get the classicly.com URL for an audiobook" do
    audiobook = FactoryGirl.create(:audiobook)
    
    data = {
        "action"       => "get_classicly_url_for_book",
        "audiobook_id" => audiobook.id
      }
      
    post "query", :json_data => data.to_json
    
    response.body.should include("http://www.classicly.com")
  end
  
  it "should be able to update a book's description" do
    book = FactoryGirl.create(:book, :description => "old description")
    
    data = {
        "book_id"     => book.id,
        "action"      => "update_book_description",
        "description" => "new description"
      }
    
    post "create", :json_data => data.to_json
    
    response.should be_success
    book.reload.description.should == "new description"
  end
  
end