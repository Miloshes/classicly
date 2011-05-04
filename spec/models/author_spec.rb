require 'spec_helper'

describe Author do
  before :each do
    @author = Author.make!
  end

  describe '#featured_book' do
    before :each do
      @book = Book.make! :author => @author
    end
    
    it 'should not be nil' do
      @author.featured_book.should_not be_nil
    end

    it 'should belong to the author' do
      @author.featured_book.author.should == @author
    end
  end

  describe '#related books' do
    before :each do
      # set 5 blessed books with the author
      @books = []
      1.upto(5){|i| @books << Book.make!(:author => @author, :blessed => true)}
      # now set non blessed books
      1.upto(5){|i| @books << Book.make!(:author => @author, :blessed => false) }
    end
    
    it 'should bring author\'s blessed books before non blessed' do
      related_books = @author.related_books(8)
      blessed_count = related_books.select {|book| book.blessed }.count
      non_blessed_count = related_books.select {|book| !book.blessed}.count
      blessed_count.should == 5
      non_blessed_count.should == 3
    end
  end
end
