require 'spec_helper'

describe Collection do

  # NOTE: refactor! - Zsolt
  describe '#needs_canonical_link' do

    before :each do
      @collection = Collection.new(:book_type => 'book')
      books = double('Books')
      books.stub(:count).and_return(20)
      @collection.stub(:books).and_return(books)
    end

    it 'should return something' do
      @collection.needs_canonical_link?(10).should be_true
    end

    it 'should return false when the collection has just one page of books' do
      @collection.needs_canonical_link?(20).should be_false
    end
  end

  describe '#featured_audiobook' do

    before :each do
      @collection = FactoryGirl.create(:collection, :book_type => 'audiobook', :collection_type => 'Collection')

      1.upto(10) do |i|
        @collection.audiobooks << FactoryGirl.create(:audiobook, :pretty_title => 'hummies audiobook #{i}')
      end
    end

    context "when the collection doesn't have blessed audiobooks" do
      it 'should not return nil' do
        @collection.featured_audiobook.should_not be_nil
      end
    end

    context 'when the collection does have blessed books' do 
      it 'should return a blessed book' do
        @collection.audiobooks << FactoryGirl.create(:audiobook, :blessed => true)
        @collection.featured_audiobook.blessed.should be_true
      end
    end
  end

  describe '#featured_book' do

    before :each do
      @collection = FactoryGirl.create(:collection, :book_type => 'book', :collection_type => 'collection')

      1.upto(10) do |i|
        @collection.books << FactoryGirl.create(:book, :pretty_title => 'hummies book #{i}')
      end
    end

    context "when the collection doesn't have blessed books" do
      it 'should not return nil' do
        @collection.featured_book.should_not be_nil
      end
    end

    context 'when the collection does have blessed books' do 
      it 'should return a blessed book' do
        @collection.books.last.update_attribute(:blessed, true)

        @collection.featured_book.blessed.should be_true
      end
    end

  end


  describe '#thumbnail_books' do

    context 'thumbnail books of Book Class' do

      before :each do
        @collection = FactoryGirl.create(:collection, :book_type => 'book', :collection_type => 'collection')
        @collection.books = []

        1.upto(10) do |i|
          @collection.books << FactoryGirl.create(:book, :pretty_title => "hummies book #{i}")
        end

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

    context 'thumbnail books of audiobook class' do
      before :each do
        @collection = FactoryGirl.create(:collection, :book_type => 'audiobook', :collection_type => 'Collection')

        1.upto(10) do |i|
          @collection.audiobooks << FactoryGirl.create(:audiobook, :pretty_title => 'hummies audiobook #{i}')
        end
      end

      it 'should return audiobooks' do
        @collection.thumbnail_books(2).first.should be_an_instance_of(Audiobook)
      end

      context 'when we ask afor more books than available' do
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

  describe '#has_audiobook_counterpart?' do

    before :each do
      @collection = FactoryGirl.create(:collection, :book_type => 'book', :collection_type => 'collection', :name => 'My Collection')
    end

    context 'when there is an audiobook counterpart' do

      it 'should return true' do
        FactoryGirl.create(:collection, :book_type => 'audiobook', :collection_type => 'collection', :name => 'My Collection', :cached_slug => 'my-collection-audiobooks')
        @collection.has_audiobook_counterpart?.should be_true
      end

    end

    context "when there isn't an audiobook counterpart" do
      it 'should return false' do
        @collection.has_audiobook_counterpart?.should be_false
      end
    end

    context 'when calling the method in an audiobook collection' do
      it 'should return false' do
        @audiobook_collection = FactoryGirl.create(:collection, :book_type => 'audiobook', :collection_type => 'collection', :name => 'My Collection', :cached_slug => 'my-collection-audiobooks')
        @audiobook_collection.has_audiobook_counterpart?.should be_false
      end
    end

  end

  describe '#has_book_counterpart?' do

    before :each do
      @collection = FactoryGirl.create(:collection, :book_type => 'audiobook', :collection_type => 'collection', :name => 'My Collection', :cached_slug => 'my-collection-audiobooks')
    end

    context 'when there is a book counterpart' do
      it 'should return true' do
        FactoryGirl.create(:collection, :book_type => 'book', :collection_type => 'collection', :name => 'My Collection', :cached_slug => 'my-collection')
        @collection.has_book_counterpart?.should be_true
      end
    end
    
    context "when there isn't a book counterpart" do
      it 'should return false' do
        @collection.has_book_counterpart?.should be_false
      end
    end

    context 'when calling the method in an book collection' do
      it 'should return false' do
        @book_collection = FactoryGirl.create(:collection, :book_type => 'book', :collection_type => 'collection', :name => 'My Collection', :cached_slug => 'my-collection')
        @book_collection.has_book_counterpart?.should be_false
      end
    end

  end
  
  describe '#audiobook_collection_slug' do

    before :each do
      @collection = FactoryGirl.create(:collection, :book_type => 'book', :collection_type => 'collection', :name => 'My Collection')
    end

    context 'when this collection does not have an audiobook counterpart' do
      it 'should return nil' do
        @collection.audiobook_collection_slug.should be_nil
      end
    end

    context 'when there is a counterpart audiobook collection' do

      it 'should return the audiobook collection slug' do
        FactoryGirl.create(:collection, :book_type => 'audiobook', :collection_type => 'collection', :name => 'My Collection', :cached_slug => 'my-collection-audiobooks')
        @collection.audiobook_collection_slug.should == 'my-collection-audiobooks'
      end

    end

  end
  describe '#audiobook_collection_book_slug' do

    before :each do
      # Given we have an audiobook collection
      @collection = FactoryGirl.create(:collection, :book_type => 'audiobook', :collection_type => 'collection', :name => 'My Collection', :cached_slug => 'my-collection-audiobooks')
    end

    context 'when this collection does not have a book counterpart' do
      it 'should return nil' do
        @collection.audiobook_collection_book_slug.should be_nil
      end
    end

    context 'when there is a counterpart book collection' do

      it 'should return the book collection slug' do
        # And a book collection exists for that audiobook collection
        FactoryGirl.create(:collection, :book_type => 'book', :collection_type => 'collection', :name => 'My Collection')

        @collection.audiobook_collection_book_slug.should == 'my-collection'
      end

    end

  end

end
