describe "/book_highlights/show.html.haml" do
  before :each do
    @highlight = stub_model(BookHighlight,
      :content => 'Vlad Tepes, Dracula')
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