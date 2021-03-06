require 'acceptance/acceptance_helper'

feature 'Collections list page feature: ', %q{
  In order to browse through collections
  As a user
  I want to be able to check a list of collections in a single page and browse through it
} do

  background do
    @collection_names = %w{western romance pulp comedy drama historic epic action fantasy}
    @collection_names.each { |name| FactoryGirl.create(:collection, :collection_type => 'collection', :name => name, :book_type => 'book') }

    Collection.first.update_attribute :description, "Lorem Ipsum Dolorem Sit Amet"
    # And Given I have a genre collection
    FactoryGirl.create(:collection, :collection_type => 'genre', :name => 'Genre Collection', :book_type => 'book')

    # When I visit the collections page
    visit collections
  end


  scenario 'Featured Collection' do

    within('div#featured-collection') do

      within('.cover-column .cover') do
        # Then I see a big cover for this book:
        page.should have_selector('a')
        page.should have_selector('a img')
        # And I see a text 'Featured Collection':
      end

      page.should have_css('.detail-column h1')
       # And I see a list of thumb covers for this collection

      within('.books-and-link') do
        page.should have_css('div.cover')
        page.should have_css('div.cover a img')
        # and I should see a button to browse this collection
        page.should have_css('a.browse-collection img')
      end
    end
  end


  scenario 'Viewing a list of collections' do

    # Then I should see the title <Collections>
    within('#collection-list') do

      within('h2') do
        page.should have_content('Collections')
      end

      within('ul.collection') do
        page.should have_css('li .covers .cover img')

        # And I should see a button to browse each collection
        page.should have_css("li.collection .browse-this-collection a img")
      end

    end

    #And I should see the Genre collection
    page.should have_content("Genre Collection")
  end


  scenario 'Viewing a list of audiobook collections' do

    # Given there are audiobook collections

    1.upto(2) do
      collection = FactoryGirl.create(:collection, :book_type => 'audiobook', :collection_type => 'collection')
      1.upto(5) do|i|
        audiobook = FactoryGirl.create(:audiobook, :pretty_title => "hummies_#{i}")
        collection.audiobooks << audiobook
      end
    end

    # And given we have an audiobook genre collection
    FactoryGirl.create(:collection, :book_type => 'audiobook', :collection_type => 'genre', :name => 'Genre Audiobooks')

    # When I click the Audiobooks switch
    within('.audiobook-switcher') do
      click_on 'Audiobooks'
    end

    #Then I should see the title Audiobook Collections
    page.should have_content('Audiobook Collections')

    within('ul.collection') do

      # And I should see covers for this collection
      page.should have_css('li .covers .cover img')

      # And I should see a button to browse each collection
      page.should have_css("li.collection .browse-this-collection a img")

    end

    # And I should see the genre collection
    page.should have_content('Genre Audiobooks')
  end


  scenario 'going to the featured collection route' do

    within('div#featured-collection') do

      slug = collection_slug find('.books-and-link a.browse-collection')[:href]

      # When I click the featured collection
      find('.books-and-link a.browse-collection').click()

      # Then I should be in the SEO path for this collection
      current_path.should == "/#{slug}"

    end
  end


  scenario 'individual collection page' do

    collection = FactoryGirl.create(:collection, :collection_type => 'collection', :name => 'Folk')

    FactoryGirl.create(:seo_slug, :seoable => collection, :slug => 'folk')

    # Given I am on the collections page:
    visit collections

    # When I click the link to the 'Folk' collection
    find(:xpath, "//a[text()='Folk']").click

    # Then I should be in the path for this collection
    current_path.should == "/folk"

    # And I should see that this is the folk's collection page
    page.should have_content("Folk Books")
  end

end
