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

  describe 'if I ask a collection if it has an associated collection of type <audio>,' do

    before :each do
      @collection = FactoryGirl.create(:collection, :book_type => 'book', :collection_type => 'collection', :name => 'My Collection')
    end

    context 'when it does,' do

      it 'should tell us that yeah, it is true' do
        @collection.audio_collection = FactoryGirl.create(:collection, :book_type => 'audiobook', :collection_type => 'collection', :name => 'My Collection', :cached_slug => 'my-collection-audiobooks')
        
        @collection.has_audio_collection?.should be_true
      end

    end

    context "when it does not," do
      it 'should say no, it is false' do
        @collection.has_audio_collection?.should be_false
      end
    end

    context 'if the collection is already of type <audio>' do
      it 'should say false, I am an audiocollection, duh' do
        @audiobook_collection = FactoryGirl.create(:collection, :book_type => 'audiobook', :collection_type => 'collection', :name => 'My Collection', :cached_slug => 'my-collection-audiobooks')
        @audiobook_collection.has_audio_collection?.should be_false
      end
    end

  end

  describe 'if I ask a collection if it has an associated collection of type <book>,' do

    before :each do
      @collection = FactoryGirl.create(:collection, :book_type => 'audiobook', :collection_type => 'collection', :name => 'My Collection', :cached_slug => 'my-collection-audiobooks')
    end

    context 'when  it does' do
      it 'should tell us yeah, it is true' do
        collection = FactoryGirl.create(:collection, :book_type => 'book', :collection_type => 'collection', :name => 'My Collection', :cached_slug => 'my-collection')
        collection.audio_collection = @collection
        @collection.belongs_to_book_collection?.should be_true
      end
    end
    
    context "when it does not" do
      it 'should say no, it is false' do
        @collection.belongs_to_book_collection?.should be_false
      end
    end

    context 'if the collection is of book type' do
      it 'should say false, I am a book type collection duh' do
        @book_collection = FactoryGirl.create(:collection, :book_type => 'book', :collection_type => 'collection', :name => 'My Collection', :cached_slug => 'my-collection')
        @book_collection.belongs_to_book_collection?.should be_false
      end
    end

  end
end
