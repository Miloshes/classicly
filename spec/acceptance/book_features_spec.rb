require 'acceptance/acceptance_helper'

feature 'Book features', %q{
  In order to read
  As a user
  I want to be able to download and read books online
} do

  background do
    @author = Author.make!(:name => 'Bram Stoker')
    @book = Book.make!(:author => @author, :pretty_title => 'Dracula', :is_rendered_for_online_reading => true)
  end
  
  scenario 'Reading a book online' do
    # Given I have a book and this book is to read online 
    @slug_read_online = SeoSlug.make!(:seoable_id => @book.id, :seoable_type => 'Book', :format => 'online')
    # When I am in the book detail page
    visit author_book_path(@author, @book)
    # I should see a button to read it online
    page.should have_css('.read a')
  end

end
