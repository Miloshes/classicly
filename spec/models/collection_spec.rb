require 'spec_helper'

describe Collection do
  context 'book collections' do
    describe 'default ordering by downloaded count' do
      before :each do
        @book_1 = Book.make!
        @book_2 = Book.make!
        #make sure the downloaded count is predictable
        @collection_1 = Collection.make(:books)
        @collection_2 = Collection.make(:books)
        # associate the books with the collections
        @book_1.collections <<  @collection_1
        @book_2.collections << @collection_2
        # save both books
        @book_1.save!
        @book_2.save!
      end
      it 'should fetch the collection ordered by the most downloaded count' do
        # simulate @book_2  in @collection_2 has been downloaded enough  times to get over collection_1
        @book_2.update_attribute :downloaded_count, 35
        # update the downloaded counts of collections (called in a rake in production)
        Collection.update_cache_downloaded_count
        # verify that @collection_2 appears before @collection_1
        collections = Collection.select('name').map(&:name)
        collections.index(@collection_2.name).should < collections.index(@collection_1.name)
        # now simulate @book_1 has been downloaded more times
        @book_1.update_attribute :downloaded_count, 40
        # update the downloaded counts of collections
        Collection.update_cache_downloaded_count
        collections = Collection.select('name').map(&:name)
        collections.index(@collection_1.name).should < collections.index(@collection_2.name)
      end
    end
  end

  context 'audiobook collections' do
    describe 'default ordering by downloaded count' do
      before :each do
        @audio_book_1 = Audiobook.make!
        @audio_book_2 = Audiobook.make!
        #make sure the downloaded count is predictable
        @collection_1 = Collection.make(:audiobooks)
        @collection_2 = Collection.make(:audiobooks)
        # associate the books with the collections
        @audio_book_1.collections <<  @collection_1
        @audio_book_2.collections << @collection_2
        # save both books
        @audio_book_1.save!
        @audio_book_2.save!
      end
      it 'should fetch the collections ordered by the most downloaded count' do
        # simulate @book_2  in @collection_2 has been downloaded enough  times to get over collection_1
        @audio_book_2.update_attribute :downloaded_count, 35
        # update the downloaded counts of collections (called in a rake in production)
        Collection.update_cache_downloaded_count
        # verify that @collection_2 appears before @collection_1
        collections = Collection.select('name').map(&:name)
        collections.index(@collection_2.name).should < collections.index(@collection_1.name)
        # now simulate @book_1 has been downloaded more times
        @audio_book_1.update_attribute :downloaded_count, 40
        # update the downloaded counts of collections
        Collection.update_cache_downloaded_count
        collections = Collection.select('name').map(&:name)
        collections.index(@collection_1.name).should < collections.index(@collection_2.name)
      end
    end
  end
end
