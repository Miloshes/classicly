class AddDownloadedCountToAudiobooks < ActiveRecord::Migration
  def self.up
    add_column :audiobooks, :downloaded_count, :integer, :default => 0
  end

  def self.down
    remove_column :audiobooks, :downloaded_count
  end
end
