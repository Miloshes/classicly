require 'spec_helper'

describe Book do
  before :each do
    @book = Book.make!
  end
  
  describe '#read_online?' do
    it 'should return true when the book is rendered for online reading' do
      @book.update_attribute(:is_rendered_for_online_reading, true)
      @book.read_online?.should be_true
    end
    it 'should return false when the book is not rendered for online reading' do
      @book.update_attribute(:is_rendered_for_online_reading, false)
      @book.read_online?.should be_false
    end
  end
end
