require 'acceptance/acceptance_helper'

  feature 'Read a book online', %q{
    In order to enjoy my book online
    As a user
    I want to be able to use an ereader online and read my book
  } do
    background do
      # FIXME: parse_seo function should not depend on these
      @validation_author    = Fabricate(:author, :name => "Ignacio De La Madrid")
      @validation_book      = Fabricate(:book, :author => @validation_author)
      @validation_audiobook = Fabricate(:audiobook, :author => @validation_author)

      # Fabricator's default is metadescription, Book
      Fabricate(:seo_default, :default_value => 'This is $(pretty_title) metadescription')
      Fabricate(:seo_default, :object_attribute => 'webtitle', :default_value => 'This is $(pretty_title) webtitle')
      Fabricate(:seo_default, :object_type => 'Audiobook', :default_value => 'This is $(pretty_title) metadescription')
      Fabricate(:seo_default, :object_type => 'Audiobook', :object_attribute => 'webtitle', :default_value => 'This is $(pretty_title) webtitle')


      # Given I have a book and this book is to read online
      @author           = Fabricate(:author, :name => 'Bram Stoker')
      @book             = Fabricate(:book, :author => @author, :pretty_title => 'Dracula', :is_rendered_for_online_reading => true)
      @slug_read_online = Fabricate(:seo_slug, :seoable_id => @book.id, :seoable_type => 'Book', :format => 'online', :slug => 'read-dracula-online-free')
    end


    scenario 'the book can be read online' do
      # When I am in the book detail page
      visit author_book_path(@author, @book)

      # I should see a button to read it online
      page.should have_css('.read a')
    end

    scenario 'Going to read online page with a book that can not be read(does not have book pages)' do
      # Given I have a book which can't be read online
      @book.update_attribute(:is_rendered_for_online_reading, false)

      # When I am in the book detail page
      visit seo_path(@slug_read_online.slug)

      #Then I should be on the read online page
      page.should have_content("Read Dracula Online Free")

      # And I should not see a button to read it online
      page.should_not have_css('#read_online_button_container')
    end

  end

  feature 'Show download links for matching audiobooks in the book page', %q{
    In order to have a shortcut for audiobooks
    As a user
    I want to be able to see a link to audiobooks if the current book is available in audio
  } do

    background do
      # FIXME: parse_seo function should not depend on these
      @validation_author    = Fabricate(:author, :name => "Ignacio De La Madrid")
      @validation_book      = Fabricate(:book, :author => @validation_author)
      @validation_audiobook = Fabricate(:audiobook, :author => @validation_author)

      # Fabricator's default is metadescription, Book
      Fabricate(:seo_default, :default_value => 'This is $(pretty_title) metadescription')
      Fabricate(:seo_default, :object_attribute => 'webtitle', :default_value => 'This is $(pretty_title) webtitle')
      Fabricate(:seo_default, :object_type => 'Audiobook', :default_value => 'This is $(pretty_title) metadescription')
      Fabricate(:seo_default, :object_type => 'Audiobook', :object_attribute => 'webtitle', :default_value => 'This is $(pretty_title) webtitle')

      #Given we have a book:
      @author = Fabricate(:author, :name => 'Victor Hugo', :cached_slug => 'victor-hugo')
      @book   = Fabricate(:book, :author => @author, :pretty_title => 'Les miserables', :cached_slug => 'les-miserables', :has_audiobook => true)
    end

    scenario 'downloading an audiobook from the book view' do
      # And an audiobook exists for that book
      @audiobook  = Fabricate(:audiobook, :author => @author, :pretty_title => 'Les miserables', :cached_slug => 'les-miserables-audiobook')
      @slug       = Fabricate(:seo_slug, :seoable_id => @audiobook.id, :seoable_type => 'Audiobook', :format => 'mp3', :slug => 'download-les-miserables-audiobook-mp3')

      #when I go to the book view
      visit author_book_path(@author, @book)

      # And I click the download mp3 button
      find(:xpath, "//a[@class='download-as-mp3']").click

      # then I should see the download link for the mp3 title
      within('#book-metadata h1') do
        page.should have_content('Download Les miserables MP3')
      end
    end

    scenario 'downloading an audiobook from the book view when there is no audiobook for the book' do
      #Given the book does not have a matching audiobook
      @book.update_attribute(:has_audiobook, false)

      #when I go to the book view
      visit author_book_path(@author, @book)

      # Then I should not see the download link for the mp3
      page.should_not have_xpath("//a[@class='download-as-mp3']")
    end
  end


  feature 'Download book', %q{
  In order to read my book offline
  As a user
  I want to be able to download it
  } do

    background do
      # FIXME: parse_seo function should not depend on these
      @validation_author    = Fabricate(:author, :name => "Ignacio De La Madrid")
      @validation_book      = Fabricate(:book, :author => @validation_author)
      @validation_audiobook = Fabricate(:audiobook, :author => @validation_author)

      # Fabricator's default is metadescription, Book
      Fabricate(:seo_default, :default_value => 'This is $(pretty_title) metadescription')
      Fabricate(:seo_default, :object_attribute => 'webtitle', :default_value => 'This is $(pretty_title) webtitle')
      Fabricate(:seo_default, :object_type => 'Audiobook', :default_value => 'This is $(pretty_title) metadescription')
      Fabricate(:seo_default, :object_type => 'Audiobook', :object_attribute => 'webtitle', :default_value => 'This is $(pretty_title) webtitle')
    end



    scenario 'downloading an available book' do

      # Given I have a book and this book has a download page for pdf
      author            = Fabricate(:author, :name => 'Brammy Stokes')
      book              = Fabricate(:book, :author => author, :pretty_title => 'Patula')
      landing_page_slug = Fabricate(:seo_slug, :seoable_id => book.id,  :seoable_type => 'Book', :format => 'pdf', :slug => 'download-patula-pdf')
      download_format   = Fabricate(:download_format, :book_id => book.id, :format => 'pdf')

      1.upto(5) {|i| Fabricate(:book, :author => author, :blessed => true)} #needed because of the related books in the UI

      # When I am on the book detail page
      visit author_book_path(author, book)

      # And I click the download as PDF button
      within('.download') do
        find(:xpath, ".//a[1]").click
      end

      # And I click the download button
      within('.download-highlight') do
        find(:xpath, ".//a[1]").click
      end


      # Then I should see that this book is being downloaded
      find( ".notification-header" ).text.should include("Patula by Brammy Stokes is now downloading")

    end
  end
