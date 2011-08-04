require 'acceptance/acceptance_helper'

feature 'Seo defaults feature', %q{
  In order to control the data we show in the SEO 
  As an admin
  I want to be able to set SEO defaults
} do

  # we create a book for all the  tests
  background do
    @author = Author.make! :name => 'Kawama San'
    @book = Book.make! :pretty_title => 'Kawaii', :author => @author
  end

  scenario 'setting seo defaults for main page' do
    # we need to setup the books for the main page:
    1.upto(10){ |index| Book.make! :blessed => true }

    #given there is a default for the title in the home page: 
    SeoDefault.make!  :object_type => 'HomePage',
                      :object_attribute => 'webtitle',
                      :default_value => 'Classicly Homepage'

    # When I visit the root path.
    visit root_path
    # Then I should see the title as the admin has set it
    find('title').text.should == 'Classicly Homepage'
  end

  scenario 'going to the root page' do

    # given there is a default for the title in the blog page
    SeoDefault.make!  :object_type => 'BlogPage',
                      :object_attribute => 'webtitle',
                      :default_value => 'Classicly Blog Test'


    # When I visit the blog path.
    visit blog_path
    # Then I should see the title as the admin set it
    find('title').text.should == 'Classicly Blog Test'
  end

  scenario 'visiting the book page when the SEO defaults have been set' do
    # Given we set the title for the individual book page
     SeoDefault.make! :object_type => 'Book',
                      :object_attribute => 'webtitle',
                      :default_value => 'Download $(pretty_title) - Read Free, Read Classicly'

    # Given we set the metadescription for the individual book page
    SeoDefault.make!  :object_type => 'Book',
                      :object_attribute => 'metadescription',
                      :default_value => 'Download $(pretty_title) by $(author.name) - Read Free, Read Classicly'

    # When I visit the path for the book:
    visit author_book_path(@book.author, @book)

    # Then I should see the title as we have set it
    find( 'title' ).text.should == 'Download Kawaii - Read Free, Read Classicly'

    # And I should see that the metadescription is the one we have set
    find( 'meta[name=description]' )['content'].should == 'Download Kawaii by Kawama San - Read Free, Read Classicly'
  end

  scenario 'visiting the book page when the SEO defaults have been set and we set a custom seo for title' do
     # Given we set the title for the individual book page
     SeoDefault.make! :object_type => 'Book',
                      :object_attribute => 'webtitle',
                      :default_value => 'Download $(pretty_title) - Read Free, Read Classicly'

    # Given we set the metadescription for the individual book page
    SeoDefault.make!  :object_type => 'Book',
                      :object_attribute => 'metadescription',
                      :default_value => 'Download $(pretty_title) by $(author.name) - Read Free, Read Classicly'

    # and Given we set a seo info record for the title
    SeoInfo.make! :infoable_id => @book.id, :infoable_type => @book.class.to_s, :title => 'Custom Kawaii title'

    # When we visit the path for the book:
    visit author_book_path(@book.author, @book)

    # Then we should see the title as set, and the description as set in the defaults
    find( 'title' ).text.should == 'Custom Kawaii title'

    # And I should see that the metadescription is the one we have set
    find( 'meta[name=description]' )['content'].should == 'Download Kawaii by Kawama San - Read Free, Read Classicly'
  end

  scenario 'setting SEO defaults for the PDF landing page' do
    # Given we have a PDF version of the book:
    @pdf_slug = SeoSlug.make! :seoable_id => @book.id, :seoable_type => 'Book', :slug => 'download-kawaii-pdf', :format => 'pdf'
    DownloadFormat.make! :book_id => @book.id, :format => 'pdf'

    # And the admin has set the metadescription to show in the page
    SeoDefault.make!  :object_type => 'SeoSlug',
                      :object_attribute => 'metadescription',
                      :default_value => 'Download $(seoable.pretty_title) pdf book for your reader here at Classicly',
                      :format => 'pdf'

    #And the admin has set the title to show in the page:
    SeoDefault.make!  :object_type => 'SeoSlug',
                      :object_attribute => 'webtitle',
                      :default_value => 'Download $(seoable.pretty_title) pdf book for your reader here at Classicly',
                      :format => 'pdf'

    # When I visit the pdf landing page for this book
    visit "/#{@pdf_slug.slug}"

    # Then I should see the title as the admin set it
    find('head title').text.should == 'Download Kawaii pdf book for your reader here at Classicly'
  end

  scenario 'visiting the mp3 landing page when SEO defaults have been set' do

    #Given an audiobook exists:
    @audiobook = Audiobook.make!(:pretty_title => 'Kawaii Sound', :author => @author)
    #And there is a slug for the mp3 landing page:
    @mp3_slug = SeoSlug.make!(:seoable_id => @audiobook.id, :seoable_type => 'Audiobook', :slug => 'download-kawaii-sound-mp3', :format => 'mp3')

    # And the admin has set the metadescription to show in the page:
    SeoDefault.make!  :object_type => 'SeoSlug',
                      :object_attribute => 'metadescription',
                      :default_value => 'Download $(seoable.pretty_title) mp3 for your player here at Classicly',
                      :format => 'mp3'

    #And the admin has set the title to show in the page:
    SeoDefault.make!  :object_type => 'SeoSlug',
                      :object_attribute => 'webtitle',
                      :default_value => 'Download $(seoable.pretty_title) mp3 for your player here at Classicly',
                      :format => 'mp3'

    # When I visit the mp3 landing page:
    visit "/#{@mp3_slug.slug}"

    # Then I should see the title as the admin set it:
    find('title').text.should == 'Download Kawaii Sound mp3 for your player here at Classicly'
  end

  scenario 'visiting read online landing page when SEO defaults have been set' do

    #And there is a slug for the read online landing page:
    @read_online_slug = SeoSlug.make! :seoable_id => @book.id, :seoable_type => 'Book', :slug => 'read-kawaii-online-free', :format => 'online'

    # And the admin has set the metadescription to show in the page
    SeoDefault.make!  :object_type => 'SeoSlug',
                      :object_attribute => 'metadescription',
                      :default_value => 'Read Online $(seoable.pretty_title) with our insite reader',
                      :format => 'online'

    # And the admin has set the title to show in the page:
    SeoDefault.make!  :object_type => 'SeoSlug',
                      :object_attribute => 'webtitle',
                      :default_value => 'Read Online $(seoable.pretty_title) with our insite reader',
                      :format => 'online'

    # When I visit the  read online landing page
    visit "/#{@read_online_slug.slug}"

    # Then I should see the title as the admin set it
    find('head title').text.should == 'Read Online Kawaii with our insite reader'

  end
end
