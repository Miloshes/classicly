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
    1.upto(14) {|index| FactoryGirl.create(:collection, :book_type => 'book', :collection_type => 'author') }
    # And I am on the home page
    visit homepage
  end

  scenario 'Going to blog page from home page' do
    within :xpath, "id('nav')//ul" do
      find(:xpath, ".//li//a[text()='Blog']").click
      current_path.should == '/blog'
    end
  end

end
