require 'spec_helper'

describe SeoDefault do
  
  describe '#self.default_value_must_be_valid' do
    context 'book' do
      
      before :each do
        @author      = Author.make!(:name => 'Kawama San')
        @book        = Book.make!(:pretty_title => 'Kawaii', :author => @author)
        @seo_default = SeoDefault.make!(
          :object_type      => 'Book',
          :object_attribute => 'metadescription',
          :default_value    => 'Read $(pretty_title) by $(author.name) only here at Classicly'
        )
      end
      
      context 'with a valid string for interpolation' do
        it 'should return true' do
          @seo_default.update_attributes(:default_value => "Read $(pretty_title) at Classicly").should be_true
          @seo_default.default_value.should == 'Read $(pretty_title) at Classicly'
        end
      end
      
      context 'with an invalid string' do
        it 'should return false' do
          @seo_default.update_attributes(:default_value => "Read $(pretty_title at Classicly").should be_false
          @seo_default.errors.should_not be_empty
        end
      end
      
    end # of book context
  end # of describe #self.default_value_must_be_valid
  
  describe '#self.parse_default_value' do
    
    context 'when a valid string is set as the value for the attribute' do
      context 'with book' do
        it 'should return the parsed string' do
          @author      = Author.make!(:name => 'Kawama San')
          @book        = Book.make!(:pretty_title => 'Kawaii', :author => @author)
          @seo_default = SeoDefault.make!(
            :object_type      => 'Book',
            :object_attribute => 'metadescription',
            :default_value    => 'Read $(pretty_title) by $(author.name) only here at Classicly'
          )

          SeoDefault.parse_default_value(:metadescription, @book).should == 'Read Kawaii by Kawama San only here at Classicly'
        end
      end
      
      context 'with audiobook' do
        it 'should return the parsed string' do
          @author      = Author.make!(:name => 'Kawama San')
          @audiobook   = Audiobook.make!(:pretty_title => 'Kawaii', :author => @author)
          @seo_default = SeoDefault.make!(
            :object_type      => 'Audiobook',
            :object_attribute => 'metadescription',
            :default_value    => 'Listen Online $(pretty_title) by $(author.name) only here at Classicly'
          )
          
          SeoDefault.parse_default_value(:metadescription, @audiobook).should == 'Listen Online Kawaii by Kawama San only here at Classicly'
        end
      end 
    end
    
    context 'with collections' do
      context 'book collection' do
        
        before :each do
           @collection = Collection.make!(:name => 'Romance', :book_type => 'book', :collection_type => 'collection')
        end
        
        it 'should return the parsed string' do
          @seo_default = SeoDefault.make!(
            :object_type      => 'Collection',
            :object_attribute => 'metadescription',
            :default_value    => 'Read $(name) books only here at Classicly',
            :collection_type  => 'book-collection'
          )

          SeoDefault.parse_default_value(:metadescription, @collection).should == 'Read Romance books only here at Classicly'
        end
      end # of book collection context

      context 'book author collection' do
        
        before :each do
          @collection = Collection.make!(:name => 'Charles Dickens', :book_type => 'book', :collection_type => 'author')
        end

        it 'should return the parsed string' do
          @seo_default = SeoDefault.make!(
            :object_type      => 'Collection',
            :object_attribute => 'metadescription',
            :default_value    => 'Read author $(name) books only here at Classicly',
            :collection_type  => 'book-author'
          )
          
          SeoDefault.parse_default_value(:metadescription, @collection).should == 'Read author Charles Dickens books only here at Classicly'
        end
      end # of book author collection context
      
      context 'having saved both a collection and an author collection' do
        before :each do
          @author_collection       = Collection.make!(:name => 'Charles Dickens', :book_type => 'book', :collection_type => 'author')
          @collection              = Collection.make!(:name => 'Romance', :book_type => 'book', :collection_type => 'collection')
          @author_audio_collection = Collection.make!(:name => 'Charles Dickens', :book_type => 'audiobook', :collection_type => 'author')
          @audio_collection        = Collection.make!(:name => 'Romance', :book_type => 'audiobook', :collection_type => 'collection')
          SeoDefault.make!(
            :object_type      => 'Collection',
            :object_attribute => 'metadescription',
            :default_value    => 'Read $(name) books only here at Classicly',
            :collection_type  => 'book-collection'
          )
          SeoDefault.make!(
            :object_type      => 'Collection',
            :object_attribute => 'metadescription',
            :default_value    => 'Read author $(name) books only here at Classicly',
            :collection_type  => 'book-author'
          )
          SeoDefault.make!(
            :object_type      => 'Collection',
            :object_attribute => 'metadescription',
            :default_value    => 'Read $(name) collection audiobooks only here at Classicly',
            :collection_type  => 'audiobook-collection'
          )
          SeoDefault.make!(
            :object_type      => 'Collection',
            :object_attribute => 'metadescription',
            :default_value    => 'Read author $(name) audiobooks only here at Classicly',
            :collection_type  => 'audiobook-author'
          )
        end
        
        it 'should return the parsed string' do
          SeoDefault.parse_default_value(:metadescription, @collection).should == 'Read Romance books only here at Classicly'
          SeoDefault.parse_default_value(:metadescription, @author_collection).should == 'Read author Charles Dickens books only here at Classicly'
          SeoDefault.parse_default_value(:metadescription, @author_audio_collection).should == 'Read author Charles Dickens audiobooks only here at Classicly'
          SeoDefault.parse_default_value(:metadescription, @audio_collection).should == 'Read Romance collection audiobooks only here at Classicly'
        end
      end # of collection and author collection context
    end # of 'with collections' context
    
    context 'landing pages slugs' do
      
      before :each do
        @author = Author.make!(:name => 'Kawama San')
        @book   = Book.make!(:pretty_title => 'Kawaii', :author => @author)
      end
      
      context 'pdf landing page' do
        before :each do
          @pdf_slug = SeoSlug.make!(:seoable_id => @book.id, :seoable_type => 'Book', :slug => 'download-kawaii-pdf', :format => 'pdf')
          SeoDefault.make!(
            :object_type      => 'SeoSlug',
            :object_attribute => 'metadescription',
            :default_value    => 'Download $(seoable.pretty_title) pdf book for your reader here at Classicly',
            :format           => 'pdf'
          )
        end
        
        it 'should return a string when a valid string is set as the value for the attribute' do
          SeoDefault.parse_default_value(:metadescription, @pdf_slug).should == 'Download Kawaii pdf book for your reader here at Classicly'
        end
        
        context 'when another format coexists in the db' do
          it 'should return the correct string for both landing pages' do
            @kindle_slug = SeoSlug.make!(:seoable_id => @book.id, :seoable_type => 'Book', :slug => 'download-kawaii-kindle', :format => 'kindle')
            SeoDefault.make!(
              :object_type      => 'SeoSlug',
              :object_attribute => 'metadescription',
              :default_value    => 'Download $(seoable.pretty_title) kindle book for your reader here at Classicly',
              :format           => 'kindle'
            )

            SeoDefault.parse_default_value(:metadescription, @pdf_slug).should == 'Download Kawaii pdf book for your reader here at Classicly'
            SeoDefault.parse_default_value(:metadescription, @kindle_slug).should == 'Download Kawaii kindle book for your reader here at Classicly'
          end
        end
      end # of pdf landing page context
    
    end # of landing pages slugs context
    
  end # of describe #self.parse_default_value
  
  describe '#is_default_value_valid?' do
    
    context 'when the default value can be interpreted without problems' do
      it 'should return true' do
        @author      = Author.make!(:name => 'Kawama San')
        @book        = Book.make!(:pretty_title => 'Kawaii', :author => @author)
        @seo_default = SeoDefault.make!(
          :object_type      => 'Book',
          :object_attribute => 'metadescription',
          :default_value    => 'Read $(pretty_title) by $(author.name) only here at Classicly'
        )
        
        @seo_default.is_default_value_valid?.should be_true
      end
      
    end
  end # of describe #is_default_value_valid?
  
end