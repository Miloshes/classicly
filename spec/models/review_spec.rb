# Notes for when writing the tests:
# #create_or_update_from_ios_client_data - should not update the review if the new timestamp is less than it's creation date
# - should test: anonymous review -> normal review conversion
# - should test: normal review, but login for it does not exists -> anonymous review gets registered -> anonymous review gets 
#   turned into normal after registration
# - should test that content can be empty (ratings)

require "spec_helper"

describe Review do

  before(:each) do
    @book = mock_model(Book)
    Book.stub!(:find).and_return(@book)

    @ios_device = mock_model(IosDevice, :original_udid => "original_udid1", :ss_udid => "ss_udid1")
    @login      = mock_model(Login, :fb_connect_id => "123", :ios_device => @ios_device, :email => "test@test.com")

    Login.stub!(:find_by_fb_connect_id).and_return(@login)

    @review = Review.new(
      :reviewable => @book,
      :reviewer   => @login
    )
  end

  context "when getting created" do
    
    it "should have something reviewable assigned to it" do
      @review.reviewable = nil
      @review.should_not be_valid
    end

    it "should have a reviewer assigned to it" do
      @review.reviewer = nil
      @review.should_not be_valid
    end

    it "should sanitize it's rating" do
      @review.should_receive :sanitize_rating
      @review.save
    end

  end # end of "when getting created" context

  # test handling faulty input - very rare, but necessary
  describe "sanitizing the rating's value" do

    it "should do nothing for ratings between 1 and 5" do
      1.upto 5 do |rating|
        @review.rating = rating
        @review.should be_valid
      end
    end

    it "should convert ratings less than 1 to 1" do
      @review.rating = 0
      @review.save

      @review.rating.should == 1
    end

    it "should convert ratings above 5 to 5" do
      @review.rating = 6
      @review.save

      @review.rating.should == 5
    end

  end

end