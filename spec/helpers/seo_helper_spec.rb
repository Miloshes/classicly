require 'spec_helper'
describe SeoHelper do
  describe '#title_for_special_landing_pages' do
    before :each do
      @book = Book.make!(:pretty_title => 'Dracula')
      @audiobook = Audiobook.make!(:pretty_title => 'Dracula')
    end
    
    
    context 'having set the info from admin' do
      it 'should render the title set in the admin' do
        @seo_slug = SeoSlug.make!(:seoable_id => @book.id, :seoable_type => 'Book', :format => 'pdf')
        SeoInfo.make!(:infoable_id => @seo_slug.id, :title => 'Download Brammy Stoker Dracula PDF Book')
        title_for_special_landing_page(@seo_slug).should == 'Download Brammy Stoker Dracula PDF Book'
      end
    end
      
    context 'when no info has been set on admin' do
      context 'when the format is PDF' do
        it 'should render as <Download XYZ PDF> title' do
          @seo_slug = SeoSlug.make!(:seoable_id => @book.id, :seoable_type => 'Book', :format => 'pdf')
          title_for_special_landing_page(@seo_slug).should == 'Download Dracula PDF'
        end
      end
      context 'when the format is azw' do
        it 'should render as <Download XYZ for Kindle> title' do
          @seo_slug = SeoSlug.make!(:seoable_id => @book.id, :seoable_type => 'Book', :format => 'azw')
          title_for_special_landing_page(@seo_slug).should == 'Download Dracula for Kindle'
        end
      end
      context 'when the format is online' do
        it 'should render as <Read XYZ online for free> title' do
          @seo_slug = SeoSlug.make!(:seoable_id => @book.id, :seoable_type => 'Book', :format => 'online')
          title_for_special_landing_page(@seo_slug).should == 'Read Dracula Online for Free'
        end
      end
      
      context 'when the format is MP3' do
        it 'should render as <Download XYZ MP3 for free> title' do
          @seo_slug = SeoSlug.make!(:seoable_id => @audiobook.id, :seoable_type => 'Audiobook', :format => 'mp3')
          title_for_special_landing_page(@seo_slug).should == 'Download Dracula MP3 for Free'
        end
      end
    end
  end
end