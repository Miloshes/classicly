class AddIndexesToBookPages < ActiveRecord::Migration
  def self.up
    #add_index :book_pages, [:book_id, :page_number], :unique => true, :name => 'book_id_page_number_index_for_book_pages'
  end

  def self.down
    remove_index :book_pages, :name => 'book_id_page_number_index_for_book_pages'
  end
end
