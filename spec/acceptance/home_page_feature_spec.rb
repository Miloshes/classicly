require 'acceptance/acceptance_helper'

feature 'Home page feature: ', %q{
  In order to be able top browse around
  As a user
  I want to see a navigation bar
} do

  background do
    # Given a set of collections exists
    1.upto(10) {|index| FactoryGirl.create(:book, :blessed => true) }
    1.upto(14) {|index| FactoryGirl.create(:collection, :book_type => 'book', :collection_type => 'collection') }
    # And I am on the home page
    visit homepage
  end

  scenario 'Going to authors page from home page' do
    within :xpath, "id('nav')//ul" do
      find(:xpath, ".//li//a[text()='Authors']").click
      current_path.should == '/authors'
    end
  end

  scenario 'Going to collection page from home page' do
    within :xpath, "id('nav')//ul" do
      find(:xpath, ".//li//a[text()='Collections']").click
      current_path.should == '/collections'
    end
  end

  scenario 'Going to blog page from home page' do
    within :xpath, "id('nav')//ul" do
      find(:xpath, ".//li//a[text()='Blog']").click
      current_path.should == '/blog'
    end
  end

  scenario 'Clicking on a collection in the footer' do
    @slug = ''
    within('#footer .collections span:first') do
      @slug = collection_slug find('a')[:href]
      find('a').click
    end
    current_path.should == "/#{@slug}"
  end
end
