require 'acceptance/acceptance_helper'

feature 'Book features', %q{
  In order to read
  As a user
  I want to be able to download and read books online
} do

  background do
    @validation_author = Author.make!
    @validation_book = Book.make!(:author => @validation_author)
    @validation_audiobook = Audiobook.make!(:author => @validation_author)
    SeoDefault.make!(:object_type => 'Book', :object_attribute => 'metadescription', :default_value => 'This is $(pretty_title) metadescription')
    SeoDefault.make!(:object_type => 'Book', :object_attribute => 'webtitle', :default_value => 'This is $(pretty_title) webtitle')
    SeoDefault.make!(:object_type => 'Audiobook', :object_attribute => 'metadescription', :default_value => 'This is $(pretty_title) metadescription')
    SeoDefault.make!(:object_type => 'Audiobook', :object_attribute => 'webtitle', :default_value => 'This is $(pretty_title) webtitle')
  end

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
    find("#wrapper").text.should include("Patula by Brammy Stokes is now downloading")
  end
  
  scenario 'downloading an audiobook from the book view' do
    #Given we have a book with an audiobook
    @author = Author.make!(:name => 'Victor Hugo', :cached_slug => 'victor-hugo')
    @book = Book.make!(:author => @author, :pretty_title => 'Les miserables', :cached_slug => 'les-miserables', :has_audiobook => true)
    @audiobook = Audiobook.make!(:author => @author, :pretty_title => 'Les miserables', :cached_slug => 'les-miserables-audiobook')
    SeoSlug.make!(:seoable_id => @audiobook.id, :seoable_type => 'Audiobook', :format => 'mp3', :slug => 'download-les-miserables-audiobook-mp3')
    #when I go to the book view
    visit author_book_path(@author, @book)
    # And I click the download mp3 button
    find(:xpath, "//a[@class='download-as-mp3']").click
    # then I should see the download mp3 title
    within('#book-metadata h1') do
      page.should have_content('Download Les miserables MP3')
    end
  end
  
  scenario 'downloading an audiobook from the book view when there is no audiobook for the book' do
    #Given we have a book with an audiobook
    @author = Author.make!(:name => 'Victor Hugo', :cached_slug => 'victor-hugo')
    @book = Book.make!(:author => @author, :pretty_title => 'Les miserables', :cached_slug => 'les-miserables')
    #when I go to the book view
    visit author_book_path(@author, @book)
    # Then I should not see the download mp3 button
    page.should_not have_xpath("//a[@class='download-as-mp3']")
  end
end
