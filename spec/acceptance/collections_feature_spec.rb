require 'acceptance/acceptance_helper'

feature 'Collections feature', %q{
  In order to browse through the books in the app
  As a user
  I want 
} do
 
  scenario 'visiting a collection that has an audiobook collection counterpart' do
    # Given we have a collection and an audiocollection and its slugs
    @collection = Collection.make!(:hummies)
    @audiocollection = Collection.make!(:audiohummies)
    SeoSlug.make!(:seoable => @collection, :slug => 'hummies')
    SeoSlug.make!(:seoable => @audiocollection, :slug => 'hummies-audiobooks')
    # When I visit the collection
    visit seo_path(@collection)
    # And I click audiobooks
    within('.audiobook-switcher') do
      click_on 'Audiobooks'
    end
    #Then I should see that I am on the Hummies audiobooks page
    page.should have_content('Hummies Audiobooks')
    #And I should verify that a tooltip div exists
    page.should have_css('.audiobook-switcher .tooltip')
  end
  
  scenario 'visiting a collection that does not have an audiobook collection counterpart' do
    # Given we have a collection and an audiocollection and its slugs
    @collection = Collection.make!(:hummies)
    SeoSlug.make!(:seoable => @collection, :slug => 'hummies')
    # When I visit the collection
    visit seo_path(@collection)
    # The I should not see the audiobooks option link
    page.should_not have_css('.audiobook-switcher')
  end
  
  scenario 'visiting an audio collection that has an book collection counterpart' do
    # Given we have an audiocollection and an collection and its slugs
    @collection = Collection.make!(:hummies)
    @audiocollection = Collection.make!(:audiohummies)
    SeoSlug.make!(:seoable => @collection, :slug => 'hummies')
    SeoSlug.make!(:seoable => @audiocollection, :slug => 'hummies-audiobooks')
    # When I visit the audiocollection
    visit seo_path(@audiocollection)
    # And I click books
    within('.audiobook-switcher') do
      click_on 'Books'
    end
    # Then I should see that I am on the Hummies books page
    page.should have_content('Hummies Books')
    #And I should verify that a tooltip div exists
    page.should have_css('.audiobook-switcher .tooltip')
  end
end
