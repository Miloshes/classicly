require "spec_helper"

describe BookHighlightsController do
  
  before(:each) do
    @author = mock_model(Author, :name => "Victor Hugo", :cached_slug => "victor-hugo")
    @book = mock_model(Book, :author => @author, :pretty_title => "Les miserables", :cached_slug => "les-miserables")
    
    Book.stub(:find).and_return(@book)
    @book.stub!(:pretty_download_formats).and_return(["PDF", "Kindle", "Rtf"])
    
    @highlight = mock_model(BookHighlight,
        :book           => @book,
        :content        => "gone away",
        :cached_slug    => "gone-away",
        :origin_comment => ""
      )
    
    @highlight.stub!(:public_url).and_return("")
    BookHighlight.stub(:find_by_cached_slug).and_return(@highlight)
    
    @path_params = {:author_id => @author.cached_slug, :book_id => @book.cached_slug, :highlight_id => @highlight.cached_slug}
  end
  
  context "having a good routes setup" do
    
    it "should map GET /author-name/book-title/highlights/highlight-comes-here kind of calls to the show action" do
      url_str = "/#{@author.cached_slug}/#{@book.cached_slug}/highlights/#{@highlight.cached_slug}"
      
      {:get => url_str}.should route_to(
          :controller   => "book_highlights",
          :action       => "show",
          :author_id    => @author.cached_slug,
          :book_id      => @book.cached_slug,
          :highlight_id => @highlight.cached_slug
        )
    end
    
  end
  
  context "serving the public page for a public highlight" do
    
    it "should render the right template" do
      get "show", @path_params
      
      response.should be_success
      response.should render_template("show")
    end
    
    it "should work with the right highlight" do
      # should use the @highlight we've set up
      get "show", @path_params
      
      assigns[:highlight].should == @highlight
      
      # should use the @anonymous_highlight we're setting up
      @anonymous_highlight = mock_model(AnonymousBookHighlight,
          :book            => @book,
          :content         => "anon gone away",
          :cached_slug     => "anon-gone-away",
          :origin_comment  => ""
        )
      @anonymous_highlight.stub!(:public_url).and_return("")
      AnonymousBookHighlight.stub(:find_by_cached_slug).with(@anonymous_highlight.cached_slug).and_return(@anonymous_highlight)
      
      @path_params[:highlight_id] = @anonymous_highlight.cached_slug
      
      get "show", @path_params
      
      assigns[:highlight].should == @anonymous_highlight
    end
    
    it "should know the facebook share message and the twitter share message" do
      get "show", @path_params
      
      assigns[:message_for_twitter].should_not be_nil
      assigns[:message_for_facebook].should_not be_nil
    end
    
  end
  
end