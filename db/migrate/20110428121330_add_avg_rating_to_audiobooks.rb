class AddAvgRatingToAudiobooks < ActiveRecord::Migration
  def self.up
    add_column :audiobooks, :avg_rating, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :audiobooks, :avg_rating
  end
end
