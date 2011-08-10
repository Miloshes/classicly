require 'acceptance/acceptance_helper'

feature 'Search feature: ', %q{
  In order to find the books I want
  As a user
  I want to be able to search for them
} do

  background do
    1.upto(10){ |index| FactoryGirl.create(:book, :blessed => true) }
  end

  scenario 'searching for book' do
    @book = FactoryGirl.create(:book, :pretty_title => 'Dracula', :id => 5528) # the data must be the same we registered with indextank

    visit homepage

    fill_in 'term', :with => 'dracula'

    within :xpath, "id('search')" do
      click_on 'search_submit'
    end

    current_path.should == search_path
    selector = "li#book_5528"
    page.should have_css(selector)
  end

end
