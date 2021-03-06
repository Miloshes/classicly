class CreateBookmarks < ActiveRecord::Migration
  def self.up
    create_table :bookmarks do |t|
      t.integer :library_book_id
      t.integer :page_number
      t.text :annotation

      t.timestamps
    end
  end

  def self.down
    drop_table :bookmarks
  end
end
