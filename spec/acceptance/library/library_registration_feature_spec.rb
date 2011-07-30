require "acceptance/acceptance_helper"

feature "Library registration", %q{
  As a user of the site
  I want to be able to register with my Facebook account
  So that I can use my Library
} do
  
  background do
    @current_user = Fabricate(:login, :fb_connect_id => '123')
        
    @author   = Fabricate(:author, :name => 'Bram Stoker')    
    @book     = Fabricate(:book, :author => @author, :title => 'Dracula')

    @seo_slug = Fabricate(:seo_slug, :seoable => @book, :format => 'pdf', :slug => 'download-dracula-pdf')
    
    @download_format = Fabricate(:download_format, :book => @book)
  
    @download_book_page_url = seo_path(@seo_slug.slug)
  end
  
  scenario "register after downloading a book" do
    # Given
    #   I'm on the library page after trying to download a book
    # When
    #   I click on the Registration button
    #   and log in with Facebook
    # Then
    #   then registration page should get replaced by my Library
    
    # visit @download_book_page_url
    # click_link("download_button")
    # 
    # click_link("register-button")
    
    # TODO: login via a Facebook test user
    # TODO: check for library
  end
  
  scenario "register straight from the Library page, without downloading a book" do
    # Given
    #   I've got straight to the Library page
    # When
    #   I click on the Registration button
    #   and log in with Facebook
    # Then
    #   then registration page should get replaced by my Library
    
    # visit @download_book_page_url
    # click_link("download_button")

    # click_link("register-button")

    # TODO: login via a Facebook test user
    # TODO: check for library
  end
  
end