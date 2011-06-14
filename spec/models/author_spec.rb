require 'spec_helper'

describe Author do
  before :each do
    @author = Author.make!
  end

  describe '#featured_book' do
    before :each do
      @book = Book.make! :author => @author
      @audiobook = Audiobook.make! :author => @author
    end
    
    it 'should not be nil' do
      @author.featured_book.should_not be_nil
    end

    it 'should belong to the author' do
      @author.featured_book.author.should == @author
    end
    
    context 'when the featured book is of Audiobook class' do
      it 'should return an object of Audiobook class' do
        @author.featured_book('audiobook').should be_a_kind_of(Audiobook)
      end
    end
  end
end
