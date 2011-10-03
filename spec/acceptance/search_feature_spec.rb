require 'acceptance/acceptance_helper'

feature 'Search feature: ', %q{
  In order to find the books I want
  As a user
  I want to be able to search for them
} do

  background do
    1.upto(10){ |index| FactoryGirl.create(:book, :blessed => true) }
    FactoryGirl.create(:book, :pretty_title => 'Dracula', :id => 5528) # the data must be the same we registered with indextank

    visit homepage
  end

  scenario 'working with an autocomplete', :selenium => true do
    # When I fill in any text in my search text field
    fill_in 'term', :with => 'dracula'
    # Then I should see the autocomplete list
    page.should have_selector("ul.ui-autocomplete")
  end


  scenario 'searching for book' do

    fill_in 'term', :with => 'dracula'

    within :xpath, "id('search')" do
      click_on 'search_submit'
    end

    current_path.should == search_path
    page.should have_css('li#book_5528')
  end

end
