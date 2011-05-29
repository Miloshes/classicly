class CreateBookPages < ActiveRecord::Migration
  def self.up
    unless table_exists? :book_pages
      create_table :book_pages do |t|
        t.integer :book_id
        t.integer :page_number
        t.integer :first_character
        t.integer :last_character
        t.text :content
      end
    end
  end

  def self.down
    drop_table :book_pages
  end
end
