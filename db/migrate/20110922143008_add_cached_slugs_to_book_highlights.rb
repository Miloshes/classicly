class AddCachedSlugsToBookHighlights < ActiveRecord::Migration
  def self.up
    add_column :book_highlights, :cached_slug, :text
    add_index :book_highlights, :cached_slug, :unique => true
    
    add_column :anonymous_book_highlights, :cached_slug, :text
    add_index :anonymous_book_highlights, :cached_slug, :unique => true    
  end

  def self.down
    remove_column :book_highlights, :cached_slug
    remove_column :anonymous_book_highlights, :cached_slug
  end
end
