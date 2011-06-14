require 'acceptance/acceptance_helper'

feature 'Home page feature: ', %q{
  In order to be able top browse around
  As a user
  I want to see a navigation bar
} do

  background do
    visit homepage
  end
  
  scenario 'Going to authors page from home page' do
    within :xpath, "id('nav')//ul" do
      find(:xpath, ".//li//a[text()='Authors']").click
      current_path.should == '/authors'
    end
  end
  
  scenario 'Going to authors page from home page' do
    within :xpath, "id('nav')//ul" do
      find(:xpath, ".//li//a[text()='Collections']").click
      current_path.should == '/collections'
    end
  end
  
  scenario 'Going to authors page from home page' do
    within :xpath, "id('nav')//ul" do
      find(:xpath, ".//li//a[text()='Blog']").click
      current_path.should == '/blog'
    end
  end
end
