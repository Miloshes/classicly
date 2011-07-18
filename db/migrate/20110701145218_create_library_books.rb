class CreateLibraryBooks < ActiveRecord::Migration
  def self.up
    create_table :library_books do |t|
      t.integer :library_id
      t.integer :book_id
      
      t.datetime :last_opened
      t.integer :reading_position
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :library_books
  end
end
