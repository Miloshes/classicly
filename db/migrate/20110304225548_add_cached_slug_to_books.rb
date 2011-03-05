class AddCachedSlugToBooks < ActiveRecord::Migration
  def self.up
    add_column :books, :cached_slug, :string
  end

  def self.down
    remove_column :books, :cached_slug
  end
end
