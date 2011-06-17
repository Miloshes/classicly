require 'spec_helper'

describe Collection do
  describe '#featured_book' do
    before :each do
      @collection = Collection.make
    end
    context 'when the collection doesnt have blessed books' do
      it 'should not return nil' do
        @collection.featured_book.should_not be_nil
      end
    end
    context 'when the collection does have blessed books' do 
      before :each do
        @collection.books.first.update_attribute(:blessed, true)
      end
      it 'should return a blessed book' do
        @collection.featured_book.blessed.should be_true
      end
    end
  end
  
  describe '#thumbnail_books' do
    before :each do
      @collection = Collection.make!(:with_10_books)
    end
    
    context 'when we ask for more books than available' do
      it 'should return as much books as available minus the featured book' do
        @collection.thumbnail_books(11).count.should == 9
      end
    end
    
    context 'when we ask for a valid number of available books' do
      it 'should return as much books as asked minus the featured book' do
        @collection.thumbnail_books(7).count.should == 6
      end
    end
    
    it 'should not return the featured book' do
      @collection.thumbnail_books(10).should_not include(@collection.featured_book)
    end
  end
end
