require 'spec_helper'

describe Author do
  before :each do
    @author = Author.make!
  end

  describe '#featured_book' do
    before :each do
      @book = Book.make! :author => @author
      @audio_book = Audiobook.make! :author => @author
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

  describe '#related books' do
    context 'when fetching books' do
        before :each do
        # set 5 blessed books with the author
        @books = []
        1.upto(5){|i| @books << Book.make!(:author => @author, :blessed => true)}
        # now set non blessed books
        1.upto(5){|i| @books << Book.make!(:author => @author, :blessed => false) }
      end

      it 'should return objects of Book class' do
        related_audio_books = @author.related_books 8
        related_audio_books.first.should be_a_kind_of(Book) 
      end

      it 'should bring author\'s blessed books before non blessed' do
        related_books = @author.related_books(8)
        blessed_count = related_books.select {|book| book.blessed }.count
        non_blessed_count = related_books.select {|book| !book.blessed}.count
        blessed_count.should == 5
        non_blessed_count.should == 3
      end
    end

    context 'when fetching related audiobooks' do
      before :each do
        # set 5 blessed audiobooks with the author
        @audio_books = []
        1.upto(5){|i| @audio_books << Audiobook.make!(:author => @author, :blessed => true)}
        # now set non blessed audiobooks
        1.upto(5){|i| @audio_books << Audiobook.make!(:author => @author, :blessed => false) }
      end
      
      it 'should give back audiobooks and not books' do
        related_audio_books = @author.related_books 8, 'audiobook'
        related_audio_books.first.should be_a_kind_of(Audiobook) 
      end
    end
  end
end
