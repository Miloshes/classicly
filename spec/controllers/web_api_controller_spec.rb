require 'spec_helper'

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

describe WebApiController, "(API calls - review creation)" do
  
  before(:each) do
    @book = mock_model(Book)
    Book.stub!(:find).and_return(@book)
    
    @login = mock_model(Login, :fb_connect_id => "123")
    Login.stub_chain(:where, :first).and_return(@login)
  end
  
  it "should be able to register a book review for a user" do
    data = {
        "user_fbconnect_id" => @login.fb_connect_id,
        "device_id"         => "ASDASD",
        "book_id"           => @book.id,
        "action"            => "register_book_review",
        "content"           => "I just can't put it down. Spent the last 2 weeks reading it, can't wait to finish and read the sequel.",
        "rating"            => 5,
        "timestamp"         => "Thu Feb 10 15:09:59 +0100 2011"
      }

    post "create", :json_data => data.to_json

    response.body.should == "SUCCESS"
    Review.should have(1).record
    AnonymousReview.should have(0).records
  end
  
  it "should be able to update a review" do
    # We're creating a review in the DB to update it
    review = FactoryGirl.create(
      :review,
      :reviewable => @book, :reviewer => @login, :created_at => Time.now - 2.days
    )
    Review.stub_chain(:where, :first).and_return(review)
    
    data = {
        "user_fbconnect_id" => @login.fb_connect_id,
        "device_id"         => "ASDASD",
        "book_id"           => @book.id,
        "action"            => "register_book_review",
        "content"           => "new content",
        "rating"            => 5,
        "timestamp"         => Time.now
      }

    post "create", :json_data => data.to_json

    review.rating.should  == 5
    review.content.should == "new content"
  end

  it "should be able to register an anonymous review" do
    data = {
        "device_id" => "ASDASD",
        "book_id"   => @book.id,
        "action"    => "register_book_review",
        "content"   => "I just can't put it down. Spent the last 2 weeks reading it, can't wait to finish and read the sequel.",
        "rating"    => 5,
        "timestamp" => "Thu Feb 10 15:09:59 +0100 2011"
      }

    post "create", :json_data => data.to_json

    response.body.should == "SUCCESS"
    AnonymousReview.should have(1).record
    Review.should have(0).records
  end
  
  it "should be able to update an anonymous review" do
    # We're creating an anonymous review in the DB to update it
    anonymous_review = FactoryGirl.create(
      :anonymous_review,
      :ios_device_id => "ASDASD", :reviewable => @book, :created_at => Time.now - 2.days
    )
    AnonymousReview.stub_chain(:where, :first).and_return(anonymous_review)
    
    data = {
        "device_id" => "ASDASD",
        "book_id"   => @book.id,
        "action"    => "register_book_review",
        "content"   => "new content",
        "rating"    => 5,
        "timestamp" => Time.now
      }

    post "create", :json_data => data.to_json

    anonymous_review.rating.should  == 5
    anonymous_review.content.should == "new content"
  end
  
  # We're only testing if the creation works with an audiobook_id parameter too, all variations have been tested before for books
  it "should be able to register reviews for audiobooks too" do
    audiobook = mock_model(Audiobook)
    Audiobook.stub!(:find).and_return(audiobook)
    
    data = {
        "user_fbconnect_id" => @login.fb_connect_id,
        "device_id"         => "ASDASD",
        "audiobook_id"      => audiobook.id,
        "action"            => "register_book_review",
        "content"           => "I just can't put it down. Spent the last 2 weeks reading it, can't wait to finish and read the sequel.",
        "rating"            => 5,
        "timestamp"         => "Thu Feb 10 15:09:59 +0100 2011"
      }

    post "create", :json_data => data.to_json

    response.body.should == "SUCCESS"
    
    Review.should have(1).record
    AnonymousReview.should have(0).records
    
    Review.first.reviewable.class.should == Audiobook
  end
  
end

describe WebApiController, "(API calls - user related)" do
  
  it "should be able to register an iOS user" do
    data = {
        'structure_version'     => '1.2',
        'action'                => 'register_ios_user',
        'user_fbconnect_id'     => '1232134',
        'device_id'             => 'ASDASD',
        'user_email'            => 'test@test.com',
        'user_first_name'       => 'Zsolt',
        'user_last_name'        => 'Maslanyi',
        'user_location_city'    => 'Budapest',
        'user_location_country' => 'Hungary'
      }
    
    post "create", :json_data => data.to_json
    
    Login.should have(1).record
  end
  
  it "should be able to give information about a user" do
    login = FactoryGirl.create(:login, :fb_connect_id => "123", :first_name => "Zsolt", :email => "email_to_check@test.com")
    
    data = {
        "action"  => "get_user_data",
        "user_fbconnect_id" => "123"
      }
    
    post "query", :json_data => data.to_json
    
    parsed_response = ActiveSupport::JSON.decode(response.body)
    
    parsed_response["email"].should == "email_to_check@test.com"
    parsed_response["first_name"].should == "Zsolt"
  end

end

describe WebApiController, "(API calls - review related queries)" do

  it "should be able to give back the book ID - rating pairs for the books and audiobooks the user wrote a review for" do
    @login = FactoryGirl.create(:login, :fb_connect_id => "123")
    
    data = {
        "action"            => "get_list_of_books_the_user_wrote_review_for",
        "user_fbconnect_id" => "123",
        "structure_version" => '1.2'
      }
    
    review1 = FactoryGirl.create(:review, :reviewable => mock_model(Book), :reviewer => @login, :rating => 1)
    review2 = FactoryGirl.create(:review, :reviewable => mock_model(Book), :reviewer => @login, :rating => 5)
    review3 = FactoryGirl.create(:review, :reviewable => mock_model(Audiobook), :reviewer => @login, :rating => 1)
    review4 = FactoryGirl.create(:review, :reviewable => mock_model(Audiobook), :reviewer => @login, :rating => 5)
    
    post "query", :json_data => data.to_json
    
    parsed_response = ActiveSupport::JSON.decode(response.body)
    
    # We're expecting something like this:
    # {"books"=>[{"id"=>1013, "rating"=>1}, {"id"=>1014, "rating"=>5}], "audiobooks"=>[{"id"=>1000, "rating"=>1}, {"id"=>1001, "rating"=>5}]}
    
    parsed_response["books"].should have(2).elements
    parsed_response["books"].first.keys.sort.should == ["id", "rating"]
    
    parsed_response["audiobooks"].should have(2).elements
    parsed_response["audiobooks"].first.keys.sort.should == ["id", "rating"]
  end
  
  describe "getting the reviews for a book or audiobook, paginated" do
    
    before(:each) do
      # We want to work with real models here
      @login1 = FactoryGirl.create(:login, :fb_connect_id => "123")
      @login2 = FactoryGirl.create(:login, :fb_connect_id => "234")

      @book   = FactoryGirl.create(:book)

      @review1 = FactoryGirl.create(:review, :reviewable => @book, :reviewer => @login1, :rating => 1)
      @review2 = FactoryGirl.create(:review, :reviewable => @book, :reviewer => @login2, :rating => 5)
    end
    
    it "should work for books" do
      data = {
          "action"   => "get_reviews_for_book",
          "book_id"  => @book.id,
          "page"     => 1,
          "per_page" => 20
        }

      post "query", :json_data => data.to_json

      parsed_response = ActiveSupport::JSON.decode(response.body)

      # We're expecting something like this
      # [
      #   {
      #     "content"=>"..", "rating"=>.., "created_at"=>"..", 
      #     "fb_connect_id"=>"..", "fb_name"=>"..", "fb_location_city"=>"..", "fb_location_country"=>".."
      #   }, .....
      # ]

      parsed_response.should have(2).elements
      expected_keys = ["content", "created_at", "fb_connect_id", "fb_location_city", "fb_location_country", "fb_name", "rating"]
      parsed_response.first.keys.sort.should  == expected_keys
      parsed_response.second.keys.sort.should == expected_keys
    end
    
    it "should work for audiobooks" do
      audiobook        = FactoryGirl.create(:audiobook)
      audiobook_review = FactoryGirl.create(:review, :reviewable => audiobook, :reviewer => @login1, :rating => 1)
      
      data = {
          "action"       => "get_reviews_for_book",
          "audiobook_id" => audiobook.id,
          "page"         => 1,
          "per_page"     => 20
        }

      post "query", :json_data => data.to_json

      parsed_response = ActiveSupport::JSON.decode(response.body)

      parsed_response.should have(1).elements
      expected_keys = ["content", "created_at", "fb_connect_id", "fb_location_city", "fb_location_country", "fb_name", "rating"]
      parsed_response.first.keys.sort.should == expected_keys
    end

    it "should be paginated correctly" do
      data = {
          "action"   => "get_reviews_for_book",
          "book_id"  => @book.id,
          "page"     => 1,
          "per_page" => 1
        }

      post "query", :json_data => data.to_json

      parsed_response = ActiveSupport::JSON.decode(response.body)

      parsed_response.should have(1).elements
    end

  end # of "getting the reviews for a book or audiobook, paginated"

  describe "getting the review stats" do

    it "should work for a book" do
      book   = FactoryGirl.create(:book)
      login  = FactoryGirl.create(:login, :fb_connect_id => "123")
      review = FactoryGirl.create(:review, :reviewable => book, :reviewer => login, :rating => 1)

      data = {
          'action'  => 'get_review_stats_for_book',
          'book_id' => book.id
        }
        
      post "query", :json_data => data.to_json
      
      parsed_response = ActiveSupport::JSON.decode(response.body)
      
      # We're expecting something like this:
      # {"book_rating_average"=>1.5, "book_review_count"=>2, "classicly_url"=>"http://www.classicly.com/john-doe/book_4_pretty_title"}

      parsed_response.class.should == Hash
      parsed_response.keys.sort.should == ["book_rating_average", "book_review_count", "classicly_url"]
      parsed_response["book_review_count"].should == 1
    end
    
    it "should work for an audiobook" do
      audiobook = FactoryGirl.create(:audiobook)
      login     = FactoryGirl.create(:login, :fb_connect_id => "123")
      review    = FactoryGirl.create(:review, :reviewable => audiobook, :reviewer => login, :rating => 1)
      
      data = {
          'action'  => 'get_review_stats_for_book',
          'audiobook_id' => audiobook.id
        }
        
      post "query", :json_data => data.to_json
      
      parsed_response = ActiveSupport::JSON.decode(response.body)
      
      # We're expecting something like this:
      # {"book_rating_average"=>1.5, "book_review_count"=>2, "classicly_url"=>"http://www.classicly.com/john-doe/book_4_pretty_title"}
      
      parsed_response.class.should == Hash
      parsed_response.keys.sort.should == ["book_rating_average", "book_review_count", "classicly_url"]
      parsed_response["book_review_count"].should == 1
    end
    
  end
  
  describe "getting a list of all the ratings" do
    
    it "should work for books" do
      book   = FactoryGirl.create(:book)
      login  = FactoryGirl.create(:login, :fb_connect_id => "123")
      review = FactoryGirl.create(:review, :reviewable => book, :reviewer => login, :rating => 5)

      # book.set_average_rating
      book.update_attributes(:avg_rating => 5)
      
      data = {
          "action"    => "get_ratings_for_all_books",
          "book_type" => "book"
        }
      
      post "query", :json_data => data.to_json
      
      parsed_response = ActiveSupport::JSON.decode(response.body)
      
      # We're expecting something like this:
      # NOTE: the rating average is a string!
      # {"5779"=>"5", "5780"=>"3"}

      parsed_response.class.should == Hash
      parsed_response[book.id.to_s].should == "5"
    end
    
    it "should work for audiobooks" do
      audiobook = FactoryGirl.create(:audiobook)
      login     = FactoryGirl.create(:login, :fb_connect_id => "123")
      review    = FactoryGirl.create(:review, :reviewable => audiobook, :reviewer => login, :rating => 5)

      # audiobook.set_average_rating
      audiobook.update_attributes(:avg_rating => 5)
      
      data = {
          "action"    => "get_ratings_for_all_books",
          "book_type" => "audiobook"
        }
      
      post "query", :json_data => data.to_json
      
      parsed_response = ActiveSupport::JSON.decode(response.body)
      
      # We're expecting something like this:
      # NOTE: the rating average is a string!
      # {"5779"=>"5", "5780"=>"3"}

      parsed_response.class.should == Hash
      parsed_response[audiobook.id.to_s].should == "5"
    end
    
  end
  
  describe "getting a review for a book / audiobook a given user" do
    
    it "should work for books" do
      book   = FactoryGirl.create(:book)
      login  = FactoryGirl.create(:login, :fb_connect_id => "123")
      review = FactoryGirl.create(:review, :reviewable => book, :reviewer => login, :rating => 5)
      
      data = {
          "action"            => 'get_review_for_book_by_user',
          "book_id"           => book.id,
          "user_fbconnect_id" => "123"
        }
      
      post "query", :json_data => data.to_json
      
      parsed_response = ActiveSupport::JSON.decode(response.body)
      
      # We're expecting something like this:
      # {"content"=>"Review text comes here", "rating"=>5, "created_at"=>"2011-08-25T18:26:37Z"}

      parsed_response.class.should == Hash
      parsed_response.keys.sort.should == ["content", "created_at", "rating"]
    end
    
    it "should work for audiobooks" do
      audiobook = FactoryGirl.create(:audiobook)
      login     = FactoryGirl.create(:login, :fb_connect_id => "123")
      review    = FactoryGirl.create(:review, :reviewable => audiobook, :reviewer => login, :rating => 5)
      
      data = {
          "action"            => 'get_review_for_book_by_user',
          "audiobook_id"      => audiobook.id,
          "user_fbconnect_id" => "123"
        }
      
      post "query", :json_data => data.to_json
      
      parsed_response = ActiveSupport::JSON.decode(response.body)
      
      # We're expecting something like this:
      # {"content"=>"Review text comes here", "rating"=>5, "created_at"=>"2011-08-25T18:26:37Z"}
      
      parsed_response.class.should == Hash
      parsed_response.keys.sort.should == ["content", "created_at", "rating"]
    end
    
  end
  
end

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
