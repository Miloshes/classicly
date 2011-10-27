require "spec_helper"

describe WebApiController, "(API calls - review creation)" do
  
  before(:each) do
    @book = mock_model(Book)
    Book.stub!(:find).and_return(@book)
    
    @ios_device = mock_model(IosDevice, :original_udid => "original_udid1", :ss_udid => "ss_udid1")
    @login      = mock_model(Login, :fb_connect_id => "123", :ios_device => @ios_device)

    Login.stub_chain(:where, :first).and_return(@login)
  end
  
  describe "keeping compatibility with the API version less than 1.2" do
    
    it "should be able to register a book review for a user with a Facebook ID" do
      data = {
          "user_fbconnect_id" => @login.fb_connect_id,
          "device_ss_id"      => "ASDASD",
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
          "device_ss_id"      => "ASDASD",
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
          "device_ss_id" => "ASDASD",
          "book_id"      => @book.id,
          "action"       => "register_book_review",
          "content"      => "I just can't put it down. Spent the last 2 weeks reading it, can't wait to finish and read the sequel.",
          "rating"       => 5,
          "timestamp"    => "Thu Feb 10 15:09:59 +0100 2011"
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
        :ios_device_ss_id => "ASDASD", :reviewable => @book, :created_at => Time.now - 2.days
      )
      AnonymousReview.stub_chain(:where, :first).and_return(anonymous_review)
    
      data = {
          "device_ss_id" => "ASDASD",
          "book_id"      => @book.id,
          "action"       => "register_book_review",
          "content"      => "new content",
          "rating"       => 5,
          "timestamp"    => Time.now
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
          "device_ss_id"      => "ASDASD",
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

  context "when using the newer API" do
    
    it "should be able to register a book review for a user with a Classicly account" do
      data = {
          "structure_version" => "1.3",
          "user_email"        => @login.email,
          "device_ss_id"      => "ASDASD",
          "book_id"           => @book.id,
          "action"            => "register_book_review",
          "content"           => "I just can't put it down. Spent the last 2 weeks reading it, can't wait to finish and read the sequel.",
          "rating"            => 5,
          "timestamp"         => "Thu Feb 10 15:09:59 +0100 2011"
        }
  
      post("create",
          :json_data     => data.to_json,
          :api_key       => APP_CONFIG["api_key"],
          :api_signature => Digest::MD5.hexdigest(data.to_json + APP_CONFIG["api_secret"])
        )
  
      parsed_response = ActiveSupport::JSON.decode(response.body)
  
      parsed_response.should == {"general_response" => "SUCCESS"}
      Review.should have(1).record
      AnonymousReview.should have(0).records
    end

    it "should be able to register a book review for a user with a Facebook ID" do
      data = {
          "structure_version" => "1.3",
          "user_fbconnect_id" => @login.fb_connect_id,
          "device_ss_id"      => "ASDASD",
          "book_id"           => @book.id,
          "action"            => "register_book_review",
          "content"           => "I just can't put it down. Spent the last 2 weeks reading it, can't wait to finish and read the sequel.",
          "rating"            => 5,
          "timestamp"         => "Thu Feb 10 15:09:59 +0100 2011"
        }

      post("create",
          :json_data     => data.to_json,
          :api_key       => APP_CONFIG["api_key"],
          :api_signature => Digest::MD5.hexdigest(data.to_json + APP_CONFIG["api_secret"])
        )

      parsed_response = ActiveSupport::JSON.decode(response.body)

      parsed_response.should == {"general_response" => "SUCCESS"}
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
          "structure_version" => "1.3",
          "user_fbconnect_id" => @login.fb_connect_id,
          "device_ss_id"      => "ASDASD",
          "book_id"           => @book.id,
          "action"            => "register_book_review",
          "content"           => "new content",
          "rating"            => 5,
          "timestamp"         => Time.now
        }

      post("create",
          :json_data     => data.to_json,
          :api_key       => APP_CONFIG["api_key"],
          :api_signature => Digest::MD5.hexdigest(data.to_json + APP_CONFIG["api_secret"])
        )

      review.rating.should  == 5
      review.content.should == "new content"
    end

    it "should be able to register an anonymous review" do
      data = {
          "structure_version" => "1.3",
          "device_ss_id"      => "ASDASD",
          "book_id"           => @book.id,
          "action"            => "register_book_review",
          "content"           => "I just can't put it down. Spent the last 2 weeks reading it, can't wait to finish and read the sequel.",
          "rating"            => 5,
          "timestamp"         => "Thu Feb 10 15:09:59 +0100 2011"
        }

      post("create",
          :json_data     => data.to_json,
          :api_key       => APP_CONFIG["api_key"],
          :api_signature => Digest::MD5.hexdigest(data.to_json + APP_CONFIG["api_secret"])
        )

      parsed_response = ActiveSupport::JSON.decode(response.body)

      parsed_response.should == {"general_response" => "SUCCESS"}
      AnonymousReview.should have(1).record
      Review.should have(0).records
    end
  
    it "should be able to update an anonymous review" do
      # We're creating an anonymous review in the DB to update it
      anonymous_review = FactoryGirl.create(
        :anonymous_review,
        :ios_device_ss_id => "ASDASD", :reviewable => @book, :created_at => Time.now - 2.days
      )
      AnonymousReview.stub_chain(:where, :first).and_return(anonymous_review)
    
      data = {
          "structure_version" => "1.3",
          "device_ss_id"      => "ASDASD",
          "book_id"           => @book.id,
          "action"            => "register_book_review",
          "content"           => "new content",
          "rating"            => 5,
          "timestamp"         => Time.now
        }

      post("create",
          :json_data     => data.to_json,
          :api_key       => APP_CONFIG["api_key"],
          :api_signature => Digest::MD5.hexdigest(data.to_json + APP_CONFIG["api_secret"])
        )

      anonymous_review.rating.should  == 5
      anonymous_review.content.should == "new content"
    end
  
    # We're only testing if the creation works with an audiobook_id parameter too, all variations have been tested before for books
    it "should be able to register reviews for audiobooks too" do
      audiobook = mock_model(Audiobook)
      Audiobook.stub!(:find).and_return(audiobook)
    
      data = {
          "structure_version" => "1.3",
          "user_fbconnect_id" => @login.fb_connect_id,
          "device_ss_id"      => "ASDASD",
          "audiobook_id"      => audiobook.id,
          "action"            => "register_book_review",
          "content"           => "I just can't put it down. Spent the last 2 weeks reading it, can't wait to finish and read the sequel.",
          "rating"            => 5,
          "timestamp"         => "Thu Feb 10 15:09:59 +0100 2011"
        }

      post("create",
          :json_data     => data.to_json,
          :api_key       => APP_CONFIG["api_key"],
          :api_signature => Digest::MD5.hexdigest(data.to_json + APP_CONFIG["api_secret"])
        )

      parsed_response = ActiveSupport::JSON.decode(response.body)

      parsed_response.should == {"general_response" => "SUCCESS"}
    
      Review.should have(1).record
      AnonymousReview.should have(0).records
    
      Review.first.reviewable.class.should == Audiobook
    end
  
  end

  context "when using the legacy UDID" do
    
    it "should be able to create an anonymous review and also store the legacy UDID" do
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
      
      # check if we're actually saving the legacy UDID
      AnonymousReview.first.ios_device_id.should_not be_blank
    end
    
    it "should be able to update the anonymous review" do
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
    
    it "should save the new device_ss_id so we're actually moving away from using the legacy one" do
      data = {
          "device_id"    => "ASDASD",
          "device_ss_id" => "ss_id",
          "book_id"      => @book.id,
          "action"       => "register_book_review",
          "content"      => "I just can't put it down. Spent the last 2 weeks reading it, can't wait to finish and read the sequel.",
          "rating"       => 5,
          "timestamp"    => "Thu Feb 10 15:09:59 +0100 2011"
        }

      post "create", :json_data => data.to_json

      response.body.should == "SUCCESS"
      AnonymousReview.first.ios_device_ss_id.should == "ss_id"
    end
    
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
          "action"  => "get_review_stats_for_book",
          "book_id" => book.id
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
  
  describe "getting a review for a book / audiobook for a given user" do
    
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