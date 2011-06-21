require 'acceptance/acceptance_helper'

feature 'List Author Collections feature: ', %q{
  In order to browse through author collections
  As a user
  I want to be able to check a list of author collections in a single page and browse through it
} do

  background do
    collection_names = %w{Edgar-Poe Federico-Nietzsche Marcos-Twain Carlos-Dickens Carlota-Bronte}
    collection_names.each { |name| Collection.make!(:collection_type => 'author', :name => name) }
    # Given I am on the author collections page:
    visit authors
  end
  
  scenario 'Featured Collection' do
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
        page.should have_content('Authors')
      end
      within('ul.collection') do
        page.should have_css('li .covers .cover img')
        # And I should see a button to browse each collection
        page.should have_css("li.collection .browse-this-collection a img")
      end
    end
  end
  
  scenario 'browsing featured collection' do
    within('div#featured-collection') do
      slug = collection_slug find('.books-and-link a.browse-collection')[:href]
      # When I click the featured collection
      find('.books-and-link a.browse-collection').click()
      # Then I should be in the SEO path for this collection
      current_path.should == "/#{slug}"
    end
  end
  
  scenario 'individual collection page' do
    collection = Collection.make!( :collection_type => 'author', :name => 'Ignacio Madrid' )
    SeoSlug.make!( :seoable => collection, :slug => 'ignacio-madrid' )
    # Given I am on the collections page:
    visit authors
    # When I click the link to the 'Folk' collection
    find(:xpath, "//h5//a[text()='Ignacio Madrid']").click
    # Then I should be in the path for this collection
    current_path.should == "/ignacio-madrid"
    # And I should see that this is the folk's collection page
    page.should have_content("Ignacio Madrid Books")
  end
end

