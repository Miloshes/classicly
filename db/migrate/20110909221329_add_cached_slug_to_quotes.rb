class AddCachedSlugToQuotes < ActiveRecord::Migration
  def self.up
    add_column :quotes, :cached_slug, :string
  end

  def self.down
    remove_column :quotes, :cached_slug
  end
end
