require 'acceptance/acceptance_helper'

feature 'Seo defaults feature', %q{
  In order to control the data we show in the SEO 
  As an admin
  I want to be able to modify the SEO specs
} do

  background do
    #Given a book exists
    @author = Author.make!(:name => 'Kawama San')
    @book = Book.make!(:pretty_title => 'Kawaii', :author => @author)
  end
  
  scenario 'going to the root page' do
    #given there is a default for the title in the home page 
    SeoDefault.make!(:object_type => 'HomePage',
      :object_attribute => 'webtitle',
      :default_value => 'Classicly Homepage')
    
    #When I visit the root path
    visit root_path
    #then I should see the title as the admin set it
    find('title').text.should == 'Classicly Homepage'
  end
  
  scenario 'going to the root page' do
    #given there is a default for the title in the blog page
    SeoDefault.make!(:object_type => 'BlogPage',
      :object_attribute => 'webtitle',
      :default_value => 'Classicly Blog Test')
    
    #When I visit the blog path
    visit blog_path
    #then I should see the title as the admin set it
    find('title').text.should == 'Classicly Blog Test'
  end
  scenario 'going to the pdf landing page' do
    #And there is a slug for the pdf landing page
    @pdf_slug = SeoSlug.make!(:seoable_id => @book.id, :seoable_type => 'Book', :slug => 'download-kawaii-pdf', :format => 'pdf')
    DownloadFormat.make!(:book_id => @book.id, :format => 'pdf')
    # And the admin has set the metadescription to show in the page
    SeoDefault.make!(:object_type => 'SeoSlug',
      :object_attribute => 'metadescription',
      :default_value => 'Download $(seoable.pretty_title) pdf book for your reader here at Classicly',
      :format => 'pdf')
    #And the admin has set the title to show in the page
    SeoDefault.make!(:object_type => 'SeoSlug',
      :object_attribute => 'webtitle',
      :default_value => 'Download $(seoable.pretty_title) pdf book for your reader here at Classicly',
      :format => 'pdf')
    #When I visit the pdf landing page
    visit "/#{@pdf_slug.slug}"
    #then I should see the title as the admin set it
    find('head title').text.should == 'Download Kawaii pdf book for your reader here at Classicly'
  end
  
  scenario 'going to the mp3 landing page' do
    #Given an audiobook exists
    @author = Author.make!(:name => 'Kawama San')
    @audiobook = Audiobook.make!(:pretty_title => 'Kawaii Sound', :author => @author)
    #And there is a slug for the mp3 landing page
    @mp3_slug = SeoSlug.make!(:seoable_id => @audiobook.id, :seoable_type => 'Audiobook', :slug => 'download-kawaii-sound-mp3', :format => 'mp3')
    # And the admin has set the metadescription to show in the page
    SeoDefault.make!(:object_type => 'SeoSlug',
      :object_attribute => 'metadescription',
      :default_value => 'Download $(seoable.pretty_title) mp3 for your player here at Classicly',
      :format => 'mp3')
    #And the admin has set the title to show in the page
    SeoDefault.make!(:object_type => 'SeoSlug',
      :object_attribute => 'webtitle',
      :default_value => 'Download $(seoable.pretty_title) mp3 for your player here at Classicly',
      :format => 'mp3')
    #When I visit the mp3 landing page
    visit "/#{@mp3_slug.slug}"
    #then I should see the title as the admin set it
    find('title').text.should == 'Download Kawaii Sound mp3 for your player here at Classicly'
  end
  
  scenario 'going to the read online page' do
    #And there is a slug for the read online landing page
    @read_online_slug = SeoSlug.make!(:seoable_id => @book.id, :seoable_type => 'Book', :slug => 'read-kawaii-online-free', :format => 'online')
    # And the admin has set the metadescription to show in the page
    SeoDefault.make!(:object_type => 'SeoSlug',
      :object_attribute => 'metadescription',
      :default_value => 'Read Online $(seoable.pretty_title) with our insite reader',
      :format => 'online')
    #And the admin has set the title to show in the page
    SeoDefault.make!(:object_type => 'SeoSlug',
      :object_attribute => 'webtitle',
      :default_value => 'Read Online $(seoable.pretty_title) with our insite reader',
      :format => 'online')
    #When I visit the pdf landing page
    visit "/#{@read_online_slug.slug}"
    #then I should see the title as the admin set it
    find('head title').text.should == 'Read Online Kawaii with our insite reader'
  end
end
