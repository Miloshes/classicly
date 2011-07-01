require 'spec_helper'

describe Book do
  before :each do
    @book = Book.make!
  end
  
  describe '#read_online?' do
    it 'should return true when the book is rendered for online reading' do
      @book.update_attribute(:is_rendered_for_online_reading, true)
      @book.read_online?.should be_true
    end
    it 'should return false when the book is not rendered for online reading' do
      @book.update_attribute(:is_rendered_for_online_reading, false)
      @book.read_online?.should be_false
    end
  end
  
  describe '#audiobook_download_slug' do
    before :each do
      @book = Book.make!(:pretty_title => 'Les miserables')
    end
    
    context 'when there is no audiobook for the current book' do
      it 'should return nil' do
        @book.audiobook_download_slug.should be_nil
      end
      
      it 'should return nil even if the db is corrupted' do
        the_book = Book.find @book.id
        the_book.update_attribute :has_audiobook, true
        the_book.audiobook_download_slug.should be_nil
      end
    end
    
    describe 'when there is an audiobook correspondant to the book' do
      before :each do
        @audiobook = Audiobook.make!(:pretty_title => 'Les miserables', :cached_slug => 'les-miserables-audiobook')
        SeoSlug.create!(:seoable => @audiobook, :format => 'mp3', :slug => 'download-les-miserables-audiobook-mp3')
      end
      context 'when the database has been corrupted and the book does not report that the audiobook exists' do
        it 'should return nil' do
          the_book = Book.find @book.id
          the_book.update_attribute :has_audiobook, false
          @book.audiobook_download_slug.should be_nil
        end
      end
      context 'when the db and the slug are present' do
        it 'should return the download mp3 slug' do
          the_book = Book.find @book.id
          the_book.update_attribute :has_audiobook, true
          the_book.audiobook_download_slug.should == 'download-les-miserables-audiobook-mp3'
        end
      end
    end
  end
  
  describe '#parse_attribute_for_seo' do
    context 'when the attribute exists and holds a value' do
      it 'should return the attributes value' do
        @book = Book.make!(:pretty_title => 'kawaii')
        @book.parse_attribute_for_seo('pretty_title').should == 'kawaii'
      end
    end
    context 'when the attribute does not exist' do
      it 'should return nil' do
        @book = Book.make!(:pretty_title => 'kawaii')
        @book.parse_attribute_for_seo('some_invalid_attribute').should == nil
      end
    end
    context 'when we pass a valid association with a valid attribute' do
      it 'should return the associations attribute' do
        @author = Author.make!(:name => 'Shiretoko')
        @book = Book.make!(:pretty_title => 'kawaii', :author => @author)
        @book.parse_attribute_for_seo('author.name').should == 'Shiretoko'
      end
    end
    context 'when we pass a valid association with an invalid attribute' do
      it 'should return the associations attribute' do
        @author = Author.make!(:name => 'Shiretoko')
        @book = Book.make!(:pretty_title => 'kawaii', :author => @author)
        @book.parse_attribute_for_seo('author.money').should == nil
      end
    end
    context 'when we pass an invalid association' do
      it 'should return nil' do
        @book = Book.make!(:pretty_title => 'kawaii')
        @book.parse_attribute_for_seo('pimp.name').should == nil
      end
    end
    context 'when we pass a three level deep argument' do
      it 'should return nil' do
        @author = Author.make!(:name => 'Shiretoko')
        @book = Book.make!(:pretty_title => 'kawaii')
        @book.parse_attribute_for_seo('author.name.invalid').should == nil
      end
    end
  end
end
