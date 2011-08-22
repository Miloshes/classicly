require 'acceptance/acceptance_helper'

  feature 'Read a book online', %q{
    In order to enjoy my book online
    As a user
    I want to be able to use an ereader online and read my book
  } do
    background do
      # FIXME: parse_seo function should not depend on these
      @validation_author    = FactoryGirl.create(:author, :name => "Ignacio De La Madrid")
      @validation_book      = FactoryGirl.create(:book, :author => @validation_author)
      @validation_audiobook = FactoryGirl.create(:audiobook, :author => @validation_author)


      # Given I have a book and this book is to read online
      @author           = FactoryGirl.create(:author, :name => 'Bram Stoker')
      @book             = FactoryGirl.create(:book, :author => @author, :pretty_title => 'Dracula', :is_rendered_for_online_reading => true)
      @slug_read_online = FactoryGirl.create(:seo_slug, :seoable => @book, :format => 'online', :slug => 'read-dracula-online-free')
    end


    scenario 'the book can be read online' do
      # When I am in the book detail page
      visit author_book_path(@author, @book)

      # I should see a button to read it online
      within('.cover-column .buttons') do
        page.should have_content('Use our online reader')
      end
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
      @validation_author    = FactoryGirl.create(:author, :name => "Ignacio De La Madrid")
      @validation_book      = FactoryGirl.create(:book, :author => @validation_author)
      @validation_audiobook = FactoryGirl.create(:audiobook, :author => @validation_author)


      #Given we have a book:
      @author = FactoryGirl.create(:author, :name => 'Victor Hugo', :cached_slug => 'victor-hugo')
      @book   = FactoryGirl.create(:book, :author => @author, :pretty_title => 'Les miserables', :cached_slug => 'les-miserables', :has_audiobook => true)
    end

    scenario 'downloading an audiobook from the book view' do
      # And an audiobook exists for that book
      @audiobook  = FactoryGirl.create(:audiobook, :author => @author, :pretty_title => 'Les miserables', :cached_slug => 'les-miserables-audiobook')
      @slug       = FactoryGirl.create(:seo_slug, :seoable => @audiobook, :format => 'mp3', :slug => 'download-les-miserables-audiobook-mp3')

      #when I go to the book view
      visit author_book_path(@author, @book)

      # And I click the download mp3 button
      within('.cover-column .buttons') do
        find(:xpath, ".//a[1]").click
      end

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
      @validation_author    = FactoryGirl.create(:author, :name => "Ignacio De La Madrid")
      @validation_book      = FactoryGirl.create(:book, :author => @validation_author)
      @validation_audiobook = FactoryGirl.create(:audiobook, :author => @validation_author)
    end

    scenario 'downloading an available book' do

      # Given I have a book and this book has a download page for pdf
      author            = FactoryGirl.create(:author, :name => 'Brammy Stokes')
      book              = FactoryGirl.create(:book, :author => author, :pretty_title => 'Patula')
      landing_page_slug = FactoryGirl.create(:seo_slug, :seoable => book, :format => 'pdf', :slug => 'download-patula-pdf')
      download_format   = FactoryGirl.create(:download_format, :book => book)


      1.upto(5) {|i| FactoryGirl.create(:book, :author => author, :blessed => true)} #needed because of the related books in the UI

      # When I am on the book detail page
      visit author_book_path(author, book)

      # And I click the download as PDF button
      within('.cover-column .buttons') do
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
