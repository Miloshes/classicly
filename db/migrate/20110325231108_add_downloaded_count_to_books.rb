class AddDownloadedCountToBooks < ActiveRecord::Migration
  def self.up
    add_column :books, :downloaded_count, :integer, :default => 0
  end

  def self.down
    remove_column :books, :downloaded_count
  end
end
