require 'spec_helper'

describe DownloadFormat do

  before(:each) do
    @book = mock_model(Book)
    @download_format = DownloadFormat.new(:book => @book, :format => 'txt')
  end

  context "when getting created" do
    it "should have a book assigned to it" do
      @download_format.book = nil
      
      @download_format.should_not be_valid
    end
    
    it "should have the 'format' attribute set" do
      @download_format.format = nil
      
      @download_format.should_not be_valid
    end
  end

end