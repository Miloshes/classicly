require 'acceptance/acceptance_helper'

feature 'Adding a book to the library', %q{
  As a user of the site
  I want to my downloaded book to be added to my library
  So that I can easily access it later
} do

  background do
    @current_user     = FactoryGirl.create(:login, :fb_connect_id => '123')

    @author           = FactoryGirl.create(:author, :name => 'Bram Stoker')    
    @book             = FactoryGirl.create(:book, :author => @author, :title => 'Dracula')

    @seo_slug         = FactoryGirl.create(:seo_slug, :seoable => @book, :format => 'pdf', :slug => 'download-dracula-pdf')

    @download_format  = FactoryGirl.create(:download_format, :book => @book)

    @download_book_page_url = seo_path(@seo_slug.slug)
  end

  scenario 'user is a new user' do
    # Given
    #   I'm not logged in on the site via Facebook
    # When
    #   I visit a book download page
    #   and click the "Download and add to Library" button
    # Then
    #   I should see the library preview, which is a Facebook registration page
    #   and I should have a Registration button
    #   and I shouldn't be seeing my library as I haven't registered yet

    visit @download_book_page_url
    click_link("download_button")

    page.should have_css("#library-preview")
    page.should have_css("#register-button")
    page.should_not have_css("#library-content")
  end

  scenario 'user is already logged in via Facebook' do
    # Given
    #   I'm logged in on the site via Facebook
    # When
    #   I visit a book download page
    #   and click the "Download and add to Library" button
    # Then
    #   I should see my Library
    #   and my Library should contain my downloaded Book
    #   and I shouldn't be seeing any registration page

    # faking the Facebook login by stubbing Koala to return fake FB cookies
    fake_koala = Object.new
    Koala::Facebook::OAuth.stub(:new).and_return(fake_koala)
    fake_koala.stub(:get_user_info_from_cookies).and_return({'uid' => @current_user.fb_connect_id})

    visit @download_book_page_url
    click_link("download_button")

    page.should have_css("#library-content")
    page.should have_css("#book_#{@book.id}")
    page.should_not have_css("#library-preview")
  end

end
