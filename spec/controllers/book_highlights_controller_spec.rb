require "spec_helper"

describe BookHighlightsController do
  
  before(:each) do
  end
  
  context "having a good routes setup" do
    
    it "should map GET /author-name/book-title/highlights/highlight-comes-here kind of calls to the show action" do
      author    = mock_model(Author, :name => "Victor Hugo", :cached_slug => "victor-hugo")
      book      = mock_model(Book, :author => author, :pretty_title => "Les miserables", :cached_slug => "les-miserables")
      highlight = mock_model(Highlight, :content => "gone away", :cached_slug => "gone-away")
      
      url = "#{author.cached_slug}/#{book.cached_slug}/highlights/#{highlights.cached_slug}"
      
      {:get => url}.should route_to(:controller => "book_higlights", :action => "show")
    end
    
  end
  
end