class AddDownloadedCountAgainAudiobooks < ActiveRecord::Migration
  def self.up
    unless column_exists? :audiobooks, :downloaded_count
      add_column :audiobooks, :downloaded_count, :integer, :default => 0
    end
  end

  def self.down
  end
end
