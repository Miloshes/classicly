require 'spec_helper'

describe SeoDefault do
  
  describe '#self.parse_default_value' do
    context 'when a valid string is set as the value for the attribute' do
      context 'with book' do
        it 'should return the parsed string' do
          @author = Author.make!(:name => 'Kawama San')
          @book = Book.make!(:pretty_title => 'Kawaii', :author => @author)
          @seo_default = SeoDefault.make!(:object_type => 'Book',
            :object_attribute => 'metadescription',
            :default_value => 'Read $(pretty_title) by $(author.name) only here at Classicly')
          SeoDefault.parse_default_value(:metadescription, @book).should == 'Read Kawaii by Kawama San only here at Classicly'
        end
      end
      context 'with audiobook' do
        it 'should return the parsed string' do
          @author = Author.make!(:name => 'Kawama San')
          @audiobook = Audiobook.make!(:pretty_title => 'Kawaii', :author => @author)
          @seo_default = SeoDefault.make!(:object_type => 'Audiobook',
            :object_attribute => 'metadescription',
            :default_value => 'Listen Online $(pretty_title) by $(author.name) only here at Classicly')
          SeoDefault.parse_default_value(:metadescription, @audiobook).should == 'Listen Online Kawaii by Kawama San only here at Classicly'
        end
      end  
    end
    
    context 'when we set a non valid object attribute inside of one of the interpolation holders' do
      context 'book' do
        it 'should return a blank string inside this holder' do
          @author = Author.make!(:name => 'Kawama San')
          @book = Book.make!(:pretty_title => 'Kawaii', :author => @author)
          @seo_default = SeoDefault.make!(:object_type => 'Book',
            :object_attribute => 'metadescription',
            :default_value => 'Read $(awesome_title) by $(author.name) only here at Classicly') # awesome_title is not valid
          SeoDefault.parse_default_value(:metadescription, @book).should == 'Read $(awesome_title) by Kawama San only here at Classicly'
        end
      end
      context 'audiobook' do
        it 'should return a blank string inside this holder' do
          @author = Author.make!(:name => 'Kawama San')
          @audiobook = Audiobook.make!(:pretty_title => 'Kawaii', :author => @author)
          @seo_default = SeoDefault.make!(:object_type => 'Audiobook',
            :object_attribute => 'metadescription',
            :default_value => 'Listen $(awesome_title) by $(author.name) only here at Classicly') # awesome_title is not valid
          SeoDefault.parse_default_value(:metadescription, @audiobook).should == 'Listen $(awesome_title) by Kawama San only here at Classicly'
        end
      end
    end

    context 'when we enter an incomplete interpolation holder' do
      it 'should return the string as is' do
        @author = Author.make!(:name => 'Kawama San')
        @book = Book.make!(:pretty_title => 'Kawaii', :author => @author)
        @seo_default = SeoDefault.make!(:object_type => 'Book',
          :object_attribute => 'metadescription',
          :default_value => 'Read $(pretty_title by $(author.name) only here at Classicly') # awesome_title is not valid
        SeoDefault.parse_default_value(:metadescription, @book).should == 'Read $(pretty_title by Kawama San only here at Classicly'
      end
    end   
  end
  
  describe '#is_default_value_valid?' do
    context 'when the default value can be interpolated without problems' do
      it 'should return true' do
        @author = Author.make!(:name => 'Kawama San')
        @book = Book.make!(:pretty_title => 'Kawaii', :author => @author)
        @seo_default = SeoDefault.make!(:object_type => 'Book',
          :object_attribute => 'metadescription',
          :default_value => 'Read $(pretty_title) by $(author.name) only here at Classicly')
        @seo_default.is_default_value_valid?.should be_true
      end
    end
    context 'when the default value does have holders that cant be interpolated' do
      it 'should return false' do
        @author = Author.make!(:name => 'Kawama San')
        @book = Book.make!(:pretty_title => 'Kawaii', :author => @author)
        @seo_default = SeoDefault.make!(:object_type => 'Book',
          :object_attribute => 'metadescription',
          :default_value => 'Read $(awesome_title) by $(author.name) only here at Classicly')
        @seo_default.is_default_value_valid?.should be_false
      end
    end
  end
end