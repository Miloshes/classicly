require "spec_helper"

describe ShareMessageHandler do
  
  before(:each) do
    @author = mock_model(Author, :name => "Victor Hugo", :cached_slug => "victor-hugo")
    @book   = mock_model(Book,
        :author => @author,
        :title => "Les miserables",
        :pretty_title => "Les miserables",
        :cached_slug => "les-miserables"
      )
      
    @book.stub!(:pretty_download_formats).and_return(["PDF", "Kindle", "Rtf"])
    
    @share_message_handler = ShareMessageHandler.new
  end
    
  describe "responding to a Facebook share message request" do
    
    it "should take into account the type of the requested message"
    
    it "should respond with a title, a link, a description and a URL"
    
  end
  
  describe "responding to a Twitter share message request" do
    
    context "putting together the actual message" do

      it "should find the raw message it has to start off with" do
        message = @share_message_handler.get_message_for("twitter", "book share", :book => @book)

        # NOTE: could have a better test than this
        message.should_not be_blank
      end

      it "should replace all the variables put into the message" do
        message = @share_message_handler.get_message_for("twitter", "book share", :book => @book)

        # check for variable boundaries
        message.should_not include("{{")
        puts "\n\nFinal message: #{message}\n\n"
      end

    end
    
    it "should take into account the type of the requested message" do
      message1 = @share_message_handler.get_message_for("twitter", "book share", :book => @book)
      message2 = @share_message_handler.get_message_for("twitter", "highlight share", :book => @book)
      
      message1.should_not == message2
    end
    
    context "when responding to book share request" do
      
      it "should have a link to the book on classicly" do
        message = @share_message_handler.get_message_for("twitter", "book share", :book => @book)
        
        message.should include("http://www.classicly.com/")
      end
      
      it "shouldn't exceed the character limit" do
        message = @share_message_handler.get_message_for("twitter", "book share", :book => @book, :twitter_without_url => true)
        
        puts "\n\n Trying to short: #{message}\nlength: #{message.length}\n\n"
        # t.co links are 20characters maximum  
        message.length.should < 120
      end
      
    end
    
    context "when responding to a text selection share request" do
      
      it "should contain parts of the text selection, and a link to the highlight's public page"
      
      it "shouldn't exceed the character limit"
      
    end
    
    context "when responding to a highlight & note share request" do
      
      it "should contain parts of the text selection, and a link to the highlight's public page"
      
      it "shouldn't exceed the character limit"
      
    end
    
  end
  
end