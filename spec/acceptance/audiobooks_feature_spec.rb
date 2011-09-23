require 'acceptance/acceptance_helper'

  feature 'Audiobook individual page ', %q{
    In order to be able to read audiobooks
    As a user
    I should be able to get into and audiobook page
  } do

    background  do
      # Given I have an audiobook in the system
      @author     = FactoryGirl.create(:author, :name => 'Bram Stoker')
      @audiobook  = FactoryGirl.create(:audiobook, :author => @author, :pretty_title => 'Dracula')
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

  feature 'Download and Audiobook', %q{
    In order to be able to listen audiobooks offline
    As a user
    I want to be able to download audiobooks
  }do

    scenario 'when downloading a valid audiobook' do
      author            = FactoryGirl.create(:author, :name => "Mark Twain")
      audiobook         = FactoryGirl.create(:audiobook, :author => author, :pretty_title => "Huck Finn", :librivox_zip_link => "http://www.archive.org/download/aesop_fables_volume_one_librivox/aesop_fables_volume_one_librivox_64kb_mp3.zip", :downloaded_count => 0)
      landing_page_slug = FactoryGirl.create(:seo_slug, :seoable => audiobook, :format => 'mp3', :slug => 'download-huck-finn-mp3')

      # When I go to the audiobook page
      visit author_book_path(author, audiobook)
      # And I click to go to the mp3 download page
      within('#download-as #mp3') do
        find(:xpath, ".//a[1]").click
      end

      # And I click the download link
      within('.download-highlight') do
        find(:xpath, ".//a[1]").click
      end

      # And I should verify that the system has updated the downloaded count for this audiobook
      #visit author_book_path(author, audiobook)
      #Audiobook.find(audiobook.id).downloaded_count.should == 1
    end

  end
