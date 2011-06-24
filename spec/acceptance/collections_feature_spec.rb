require 'acceptance/acceptance_helper'

feature 'Collections feature', %q{
  In order to browse through the books in the app
  As a user
  I want 
} do

  scenario 'visiting a collection that has an audiobook collection counterpart' do
    #Given we have a collection and an audiocollection and its slugs
    @collection = Collection.make!(:hummies)
    @audiocollection = Collection.make!(:audiohummies)
    SeoSlug.make!(:seoable => @collection, :slug => 'hummies')
    SeoSlug.make!(:seoable => @audiocollection, :slug => 'hummies-audiobooks')
    # When I visit the collection
    visit seo_path(@collection)
    #And I click audiobooks
    within('.audiobook-switcher') do
      click_on 'Audiobooks'
    end
    #Then I should see that I am on the Hummies audiobooks page
    page.should have_content('Hummies Audiobooks')
  end
  
  scenario 'visiting a collection that does not have an audiobook collection counterpart' do
    #Given we have a collection and an audiocollection and its slugs
    @collection = Collection.make!(:hummies)
    SeoSlug.make!(:seoable => @collection, :slug => 'hummies')
    # When I visit the collection
    visit seo_path(@collection)
    # The I should not see the audiobooks option link
    page.should_not have_css('.audiobook-switcher')
  end
  
end
