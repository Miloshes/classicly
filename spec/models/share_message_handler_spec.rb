require "spec_helper"

# TODO:
# - test #replace_variables

describe ShareMessageHandler do
  
  before(:each) do
    @author = mock_model(Author, :name => "Victor Hugo", :cached_slug => "victor-hugo")
    @book   = mock_model(Book,
        :author       => @author,
        :title        => "Les miserables",
        :pretty_title => "Les miserables",
        :cached_slug  => "les-miserables"
      )
    @book.stub!(:pretty_download_formats).and_return(["PDF", "Kindle", "Rtf"])
      
    @ios_device = mock_model(IosDevice, :original_udid => "original_udid1", :ss_udid => "ss_udid1")
    @login = mock_model(Login, :fb_connect_id => "123", :ios_device => @ios_device)
    Login.stub_chain(:where, :first).and_return(@login)
      
    @book_highlight = mock_model(AnonymousBookHighlight,
      :first_character => 0,
      :last_character  => 9,
      :content         => "content 12",
      :book            => @book,
      :ios_device_id   => @login.ios_device.ss_udid,
      :created_at      => Time.now,
      :cached_slug     => "content-12",
      :origin_comment  => nil
    )
    @book_highlight.stub!(:public_url).and_return("http://www.classicly.com/victor-hugo/les-miserables/highlights/content-12")
    
    @share_message_handler = ShareMessageHandler.new
  end
  
  describe "selecting the base set of message templates" do
    
    it "should load the whole selection of template sets" do
      @share_message_handler.all_template_sets.class.should == Hash
      @share_message_handler.all_template_sets.keys.sort == ["facebook", "twitter"]
    end
    
    it "should chose a template set based on some rule (right now it's random)" do
      @share_message_handler.template_set.class.should == Hash
      @share_message_handler.template_set.keys.sort == ["facebook", "twitter"]
    end
    
  end
  
  describe "responding to a Facebook share message request" do
    
    before(:each) do
      @necessary_fields_for_the_response = ["title", "link", "description", "cover_url"]
    end
    
    context "putting together the actual message" do

      it "should replace all the variables put into the message" do
        message = @share_message_handler.get_message_for(:target_platform => "facebook", :message_type => "book share", :book => @book)

        # check for variable boundaries
        @necessary_fields_for_the_response.each do |field|
          message[field].should_not include("{{")
        end
      end

    end
    
    it "should respond with a title, a link, a description and a URL" do
      message = @share_message_handler.get_message_for(:target_platform => "facebook", :message_type => "book share", :book => @book)
      
      @necessary_fields_for_the_response.each do |field|
        message[field].should_not be_blank
      end
    end
    
    it "should take into account the type of the requested message" do
      message1 = @share_message_handler.get_message_for(:target_platform => "facebook", :message_type => "book share", :book => @book)
      message2 = @share_message_handler.get_message_for(
          :target_platform => "facebook",
          :message_type    => "highlight share",
          :book            => @book,
          :highlight       => @book_highlight
        )
      
      message1.should_not == message2
    end
    
    context "when responding to book share request" do
      it "should have a link to the book on classicly" do
        message = @share_message_handler.get_message_for(:target_platform => "facebook", :message_type => "book share", :book => @book)
        
        # TODO: shouldn't be hardcoded
        message["link"].should include("http://www.classicly.com/victor-hugo/les-miserables")
      end
      
      it "should have UTM tracking on the link" do
        message = @share_message_handler.get_message_for(:target_platform => "facebook", :message_type => "book share", :book => @book)
        
        %w(utm_source utm_campaign utm_medium utm_content).each do |utm_keyword|
          message["link"].should include(utm_keyword)
        end
        
        message["link"].should include("utm_campaign=book")
      end
    end

    context "when responding to highlight share request" do
      it "should have a link to the highlight on classicly" do
        message = @share_message_handler.get_message_for(
            :target_platform => "facebook",
            :message_type    => "highlight share",
            :book            => @book,
            :highlight       => @book_highlight
          )
        
        message["link"].should include(@book_highlight.public_url)
      end
      
      it "should have UTM tracking on the link" do
        message = @share_message_handler.get_message_for(
            :target_platform => "facebook",
            :message_type    => "highlight share",
            :book            => @book,
            :highlight       => @book_highlight
          )
        
        %w(utm_source utm_campaign utm_medium utm_content).each do |utm_keyword|
          message["link"].should include(utm_keyword)
        end
        
        message["link"].should include("utm_campaign=highlight")
      end
    end
    
  end
  
  describe "responding to a Twitter share message request" do
    
    it "should take into account the type of the requested message" do
      message1 = @share_message_handler.get_message_for(:target_platform => "twitter", :message_type => "book share", :book => @book)
      message2 = @share_message_handler.get_message_for(
          :target_platform => "twitter",
          :message_type    => "highlight share",
          :book            => @book,
          :highlight       => @book_highlight
        )
      
      message1.should_not == message2
    end
    
    context "putting together the actual message" do

      it "should find the raw message it has to start off with" do
        message = @share_message_handler.get_message_for(:target_platform => "twitter", :message_type => "book share", :book => @book)

        # NOTE: could have a better test than this
        message.should_not be_blank
      end

      it "should replace all the variables put into the message" do
        message = @share_message_handler.get_message_for(:target_platform => "twitter", :message_type => "book share", :book => @book)

        # check for variable boundaries
        message.should_not include("{{")
      end

    end
    
    context "when responding to book share request" do
      
      it "should have a link to the book on classicly" do
        message = @share_message_handler.get_message_for(:target_platform => "twitter", :message_type => "book share", :book => @book)
        
        message.should include("http://www.classicly.com/")
      end
      
      it "shouldn't exceed the character limit" do
        message = @share_message_handler.get_message_for(
            :target_platform     => "twitter",
            :message_type        => "book share",
            :book                => @book,
            :twitter_without_url => true
          )
        
        # t.co links are 20characters maximum
        message.length.should <= 120
      end
      
      it "should have UTM tracking on the book link" do
        message = @share_message_handler.get_message_for(:target_platform => "twitter", :message_type => "book share", :book => @book)
        
        %w(utm_source utm_campaign utm_medium utm_content).each do |utm_keyword|
          message.should include(utm_keyword)
        end
        
        message.should include("utm_campaign=book")
      end
      
    end
    
    context "when responding to a text selection share request" do
      
      it "should contain parts of the text selection, and a link to the book page" do
        message = @share_message_handler.get_message_for(
            :target_platform => "twitter",
            :message_type    => "selected text share",
            :book            => @book,
            :selected_text   => "la bourgeoisie locale"
          )
        
        message.should include("la bourgeoisie locale")
        # TODO: shouldn't be hardcoded
        message.should include("http://www.classicly.com/victor-hugo/les-miserables")
      end
      
      it "shouldn't exceed the character limit" do
        message = @share_message_handler.get_message_for(
            :target_platform     => "twitter",
            :message_type        => "selected text share",
            :book                => @book,
            :selected_text       => "la bourgeoisie locale",
            :twitter_without_url => true
          )
          
        # t.co links are 20characters maximum
        message.length.should <= 120
      end
      
      it "should have UTM tracking on the link" do
        message = @share_message_handler.get_message_for(
            :target_platform => "twitter",
            :message_type    => "selected text share",
            :book            => @book,
            :selected_text   => "la bourgeoisie locale"
          )
          
        %w(utm_source utm_campaign utm_medium utm_content).each do |utm_keyword|
          message.should include(utm_keyword)
        end
        
        message.should include("utm_campaign=text")
      end
      
    end
    
    context "when responding to a highlight share request" do
      
      it "should contain parts of the text selection, and a link to the highlight's public page" do
        message = @share_message_handler.get_message_for(
            :target_platform => "twitter",
            :message_type    => "highlight share",
            :book            => @book,
            :highlight       => @book_highlight
          )
        
        message.should include(@book_highlight.content)
        message.should include(@book_highlight.public_url)
      end
      
      it "shouldn't exceed the character limit" do
        message = @share_message_handler.get_message_for(
            :target_platform     => "twitter",
            :message_type        => "highlight share",
            :book                => @book,
            :highlight           => @book_highlight,
            :twitter_without_url => true
          )
        
        # t.co links are 20characters maximum
        message.length.should <= 120
      end
      
      it "should have UTM tracking on the link" do
        message = @share_message_handler.get_message_for(
            :target_platform => "twitter",
            :message_type    => "highlight share",
            :book            => @book,
            :highlight       => @book_highlight
          )
          
        %w(utm_source utm_campaign utm_medium utm_content).each do |utm_keyword|
          message.should include(utm_keyword)
        end

        message.should include("utm_campaign=highlight")
      end
      
    end
    
    context "when responding to a note share request" do
      
      before(:each) do
        @book_highlight.stub!(:origin_comment).and_return("adding a comment to this highlight")
      end
      
      it "should contain parts of the note, and a link to the note's parent highlight's public page" do
        message = @share_message_handler.get_message_for(
            :target_platform => "twitter",
            :message_type    => "highlight share",
            :book            => @book,
            :highlight       => @book_highlight
          )
        
        message.should include(@book_highlight.origin_comment)
        message.should include(@book_highlight.public_url)
      end
      
      it "shouldn't exceed the character limit" do
        message = @share_message_handler.get_message_for(
            :target_platform     => "twitter",
            :message_type        => "highlight share",
            :book                => @book,
            :highlight           => @book_highlight,
            :twitter_without_url => true
          )
        
        # t.co links are 20characters maximum
        message.length.should <= 120
      end
      
      it "should have UTM tracking on the link" do
        message = @share_message_handler.get_message_for(
            :target_platform => "twitter",
            :message_type    => "highlight share",
            :book            => @book,
            :highlight       => @book_highlight
          )
          
        %w(utm_source utm_campaign utm_medium utm_content).each do |utm_keyword|
          message.should include(utm_keyword)
        end

        message.should include("utm_campaign=highlight")
      end
      
    end
    
  end
  
end