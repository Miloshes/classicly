class AddDownloadedCountToCollections < ActiveRecord::Migration
  def self.up
    add_column :collections, :downloaded_count, :integer, :default => 0
  end

  def self.down
    remove_column :collections, :downloaded_count
  end
end
