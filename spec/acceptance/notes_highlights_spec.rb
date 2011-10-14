require 'acceptance/acceptance_helper'

feature 'search feature', %q{
  In order to pull more users to create notes
  As an admin
  I want to be able to push some highlights
}do

  background do
    @author         = FactoryGirl.create(:author, :name => 'Bram Stoker')
    @book           = FactoryGirl.create(:book, :author => @author, :pretty_title => 'Dracula')
    @book_highlight = FactoryGirl.create(:book_highlight, :book => @book, :content => 'Vlad Tepes, better known as Dracula...')
  end

  scenario 'showing highlight page' do
    visit "/#{@author.cached_slug}/#{@book.cached_slug}/highlights/#{@book_highlight.cached_slug}"
    page.should have_content('Vlad Tepes, better known as Dracula...')
  end

end
