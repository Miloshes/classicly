class AddHasAudiobookToBooks < ActiveRecord::Migration
  def self.up
    add_column :books, :has_audiobook, :boolean, :default => false
    Book.find_each do |book|
      has_audiobook = Audiobook.exists?(:pretty_title => book.pretty_title)
      book.update_attribute :has_audiobook, has_audiobook
      puts "Book id: #{book.id}, has_audiobook: #{has_audiobook}"
    end
  end

  def self.down
    remove_column :books, :has_audiobook
  end
end
