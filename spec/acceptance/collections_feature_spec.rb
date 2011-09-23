require 'acceptance/acceptance_helper'

feature 'Collections feature', %q{
  In order to browse through the books in the app
  As a user
  I want 
} do

  scenario 'visiting a collection that has an audiobook collection counterpart' do
    # Given we have a collection and an audiocollection and its slugs
    @collection = FactoryGirl.create(:collection, :name => 'Hummies')

    ['hummies-1', 'hummies-2'].each do|title|
      @collection.books << FactoryGirl.create(:book, :pretty_title => title)
    end

    @audiocollection = FactoryGirl.create(:collection, :book_type => 'audiobook', :name => 'Hummies')
    @collection.audio_collection = @audiocollection
    @collection.save
    
    ['audiohummies-1', 'audiohummies-2'].each do|title|
      @audiocollection.audiobooks << FactoryGirl.create(:audiobook, :pretty_title => title)
    end

    FactoryGirl.create(:seo_slug, :seoable => @collection, :slug => 'hummies')
    FactoryGirl.create(:seo_slug, :seoable => @audiocollection, :slug => 'hummies-audiobooks')

    # When I visit the collection
    visit seo_path(@collection) 
    # And I click audiobooks
    within('.audiobook-switcher .columns') do
      click_on 'Audiobooks'
    end
    # Then I should see that I am on the Hummies audiobooks page
    page.should have_content('Hummies Audiobooks')
    # And I should verify that a tooltip div exists
    page.should have_css('.audiobook-switcher .tooltip')
  end

  scenario 'show collection page with no audiobook switcher' do
    # Given we have a collection
    @collection = FactoryGirl.create(:collection, :name => 'Hummies')
    # This collection MUST have some books
    ['hummies-1', 'hummies-2'].each do|title|
      @collection.books << FactoryGirl.create(:book, :pretty_title => title)
    end
    # Collection Slug
    FactoryGirl.create(:seo_slug, :seoable => @collection, :slug => 'hummies')

    # When I visit this collection's page
    visit seo_path(@collection)

    # I should not see the audiobooks option link since it doesn't have an audio counterpart
    within('.audiobook-switcher') do
      page.should have_no_selector('a')
    end
  end
end
