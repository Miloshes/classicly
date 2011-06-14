require 'spec_helper'

describe Book do
  before :each do
    @book = Book.make
  end
  
  describe 'shortening the pretty title to a predefined limit' do
    before :each do
      @book.pretty_title = 'The count of Montecristo'
    end
    context 'when limit is shorter than pretty title length' do
      it 'should return the pretty_title, the length defined by the limit and the last 3 
        characters as periods' do
        title_to_show = @book.shorten_title 10
        title_to_show.length.should == 10
        title_to_show.should == 'The cou...'
      end
    end
    context 'when limit is greater than pretty title length' do
      it 'should return the hole pretty_title string' do
        title_to_show = @book.shorten_title 50
        title_to_show.length.should == @book.pretty_title.length
        title_to_show.should == @book.pretty_title
      end
    end
  end
end
