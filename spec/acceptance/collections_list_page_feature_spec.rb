require 'acceptance/acceptance_helper'

feature 'Collections list page feature: ', %q{
  In order to browse through collections and author collections
  As a user
  I want to be able to check a list of collections in a single page and browse through it
} do

  background do
    collection_names = %w{western romance pulp comedy drama historic epic action fantasy}
    collection_names.each { |name| Collection.make!(:collection_type => 'collection', :name => name) }
  end
  
  scenario 'Featured Collection' do
    # Given I am on the collections page:
    visit collections
    page.should have_css('div#featured-collection')
    within('div#featured-collection') do
      page.should have_css('.cover-column .cover')
      within('.cover-column .cover') do
        # Then I see a big cover for this book:
        page.should have_selector('a')
        page.should have_selector('a img')
        # And I see a text 'Featured Collection':
      end
      page.should have_css('.detail-column h1')
       # And I see a list of thumb covers for this collection
      page.should have_css('.books-and-link')
      within('.books-and-link') do
        page.should have_css('div.cover')
      end
    end
  end

end
