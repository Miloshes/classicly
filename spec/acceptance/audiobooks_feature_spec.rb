require 'acceptance/acceptance_helper'

  feature 'Audiobook individual page ', %q{
    In order to be able to read audiobooks
    As a user
    I should be able to get into and audiobook page
  } do

  background  do
    # Given I have an audiobook in the system
    @author     = Fabricate(:author, :name => 'Bram Stoker')
    @audiobook  = Fabricate(:audiobook, :author => @author, :pretty_title => 'Dracula')
  end

  scenario 'going to individual audiobook page' do
    # When I visit the audiobook page
    visit author_book_path(@author, @audiobook)

    # I should see the audiobook pretty title
    within('div#book-metadata') do
      page.should have_content('Dracula')
    end

  end
end
