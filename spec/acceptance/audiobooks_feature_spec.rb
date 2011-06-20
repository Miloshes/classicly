require 'acceptance/acceptance_helper'

feature 'Audiobooks feature: ', %q{
  In order to be able to download desired audiobooks
  As a user
  I want to browse or search through an audiobooks section
} do

  scenario 'Going to the main audiobooks page' do
    # When I visit the audiobooks path 
    visit audiobooks_path
    # I should see as ection with popular audiobooks
    page.should have_css('.row.audiobooks')
    # the featured covers should be audiobook covers
    page.should have_css('.random-audiobook')
    page.should_not have_css('.random-book')
  end

end
