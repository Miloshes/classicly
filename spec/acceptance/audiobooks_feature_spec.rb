require 'acceptance/acceptance_helper'

feature 'Audiobooks feature: ', %q{
  In order to be able to download desired audiobooks
  As a user
  I want to browse or search through an audiobooks section
} do
  
  background  do
    @author = Author.make!(:name => 'Bram Stoker')
    @audiobook = Audiobook.make!(:author => @author, :pretty_title => 'Dracula')
  end
  scenario 'visiting an audiobook page' do
    # When I visit the audiobook page
    visit author_book_path(@author, @audiobook)
    # I should see the audiobook pretty title
    within('div#book-metadata') do
      page.should have_content('Dracula')
    end
  end
end
