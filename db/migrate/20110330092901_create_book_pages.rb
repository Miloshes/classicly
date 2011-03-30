class CreateBookPages < ActiveRecord::Migration
  def self.up
    create_table :book_pages do |t|
      t.integer :book_id
      t.integer :page_number
      t.text :content
    end
  end

  def self.down
    drop_table :book_pages
  end
end
