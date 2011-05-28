class AddAvgRatingToAudiobooks < ActiveRecord::Migration
  def self.up
    unless column_exists? :audiobooks, :avg_rating
      add_column :audiobooks, :avg_rating, :integer, :default => 0, :null => false
    end
  end

  def self.down
    remove_column :audiobooks, :avg_rating
  end
end
