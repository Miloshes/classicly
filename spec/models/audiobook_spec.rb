require 'spec_helper'

describe Book do

  before :each do
    @audiobook = Audiobook.new
    @author = Author.new
  end

  describe '#parse_attribute_for_seo' do

    context 'when the attribute exists and holds a value' do

      it 'should return the attributes value' do
        @audiobook.pretty_title = 'kawaii'
        @audiobook.parse_attribute_for_seo('pretty_title').should == 'kawaii'
      end

    end

    context 'when the attribute does not exist' do

      it 'should return nil' do
        @audiobook.pretty_title = 'Kawaii'
        @audiobook.parse_attribute_for_seo('some_invalid_attribute').should == nil
      end

    end

    context 'when we pass a valid association with a valid attribute' do

      it 'should return the associations attribute' do
        @author.name =  'Shiretoko'
        @audiobook.pretty_title =  'kawaii'
        @audiobook.stub!(:author).and_return @author
        @audiobook.parse_attribute_for_seo('author.name').should == 'Shiretoko'
      end

    end

    context 'when we pass a valid association with an invalid attribute' do

      it 'should return nil' do
        @author.name = 'Shiretoko'
        @audiobook.pretty_title = 'kawaii'
        @audiobook.stub!(:author).and_return @author
        @audiobook.parse_attribute_for_seo('author.money').should == nil
      end

    end

    context 'when we pass an invalid association' do

      it 'should return nil' do
        @audiobook.parse_attribute_for_seo('pimp.name').should == nil
      end

    end

    context 'when we pass a three level deep argument' do

      it 'should return nil' do
        @author.name = 'Shiretoko'
        @audiobook.stub!(:author).and_return @author
        @audiobook.parse_attribute_for_seo('author.name.invalid').should == nil
      end

    end

  end
end
