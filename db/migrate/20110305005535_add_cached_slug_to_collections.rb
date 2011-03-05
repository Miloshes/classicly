class AddCachedSlugToCollections < ActiveRecord::Migration
  def self.up
    add_column :collections, :cached_slug, :string
  end

  def self.down
    remove_column :collections, :cached_slug
  end
end
