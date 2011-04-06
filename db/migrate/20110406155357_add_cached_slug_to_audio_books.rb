class AddCachedSlugToAudioBooks < ActiveRecord::Migration
  def self.up
    add_column :audiobooks, :cached_slug, :string
  end

  def self.down
    remove_column :audiobooks, :cached_slug
  end
end
