require "spec_helper"

describe "/book_highlights/show.html.haml" do
  
  before :each do
    @author     = FactoryGirl.create(:author, :name => 'Bram Stoker')    
    @book       = FactoryGirl.create(:book, :pretty_title => 'Dracula', :author => @author)
    @highlight  = stub_model(BookHighlight, :content => 'Vlad Tepes, Dracula')
    
    view.stub(:current_login) { nil } 
  end
  
  it 'should render the content of the highlight' do
    render
    rendered.should include('Vlad Tepes, Dracula')
  end
  
  # it "renders an image of the iTunes store apps" do
  #     render
  #     rendered.should have_selector("div", :id => "#itunes_store img")
  #   end
end