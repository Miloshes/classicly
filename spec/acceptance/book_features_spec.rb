require 'acceptance/acceptance_helper'

feature 'Book features', %q{
  In order to read
  As a user
  I want to be able to download and read books online
} do

  
  scenario 'Reading a book online' do
    @author = Author.make!(:name => 'Bram Stoker')
    @book = Book.make!(:author => @author, :pretty_title => 'Dracula', :is_rendered_for_online_reading => true)
    # Given I have a book and this book is to read online 
    @slug_read_online = SeoSlug.make!(:seoable_id => @book.id, :seoable_type => 'Book', :format => 'online')
    # When I am in the book detail page
    visit author_book_path(@author, @book)
    # I should see a button to read it online
    page.should have_css('.read a')
  end
  
  scenario 'Going to read online page with a book that can not be read(does not have book pages)' do
    @author = Author.make!(:name => 'Bram Stoker')
    @book = Book.make!(:author => @author, :pretty_title => 'Dracula', :is_rendered_for_online_reading => false)
    # Given I have a book and this book is to read online 
    @slug = SeoSlug.make!(:seoable_id => @book.id, :seoable_type => 'Book', :format => 'online', :slug => 'read-dracula-online-free')
    # When I am in the book detail page
    visit seo_path(@slug.slug)
    #Then I should be on the read online page
    page.should have_content("Read Dracula Online Free")
    # And I should not see a button to read it online
    page.should_not have_css('#read_online_button_container')
  end

  scenario 'downloading a book ' do
    # Given I have a book and this book has a download page for pdf
    @author = Author.make!(:name => 'Brammy Stokes')
    @book = Book.make!(:author => @author, :pretty_title => 'Patula', :is_rendered_for_online_reading => false)
    DownloadFormat.make!(:book_id => @book.id, :format => "pdf")
    1.upto(5) {|i| Book.make!(:author => @author, :blessed => true)}
    @slug_read_online = SeoSlug.make!(:seoable_id => @book.id, :seoable_type => 'Book', :format => 'pdf', :slug => 'download-patula-PDF')
    # when I am on the book detail page
    visit author_book_path(@author, @book)
    # And I click the download as PDF button
    within('.download') do
      find(:xpath, ".//a[1]").click
    end
    # And I click the download button
    within('.download-highlight') do
      find(:xpath, ".//a[1]").click
    end
    # Then I should see that this book is being downloaded
    within('.download-info') do
      find(:xpath, ".//h2").text.should include("Patula by Brammy Stokes is now downloading")
    end
  end
end
