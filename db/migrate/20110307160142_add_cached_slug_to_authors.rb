class AddCachedSlugToAuthors < ActiveRecord::Migration
  def self.up
    add_column :authors, :cached_slug, :string
    add_index  :authors, :cached_slug, :unique => true
  end

  def self.down
    remove_column :authors, :cached_slug
  end
end
