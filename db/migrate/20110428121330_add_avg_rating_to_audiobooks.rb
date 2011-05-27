class AddAvgRatingToAudiobooks < ActiveRecord::Migration
  def self.up
    change_table :audiobooks do |t|
      unless column_exists? :avg_rating
        t.integer :avg_rating, :default => 0, :null => false
      end
    end
  end

  def self.down
    remove_column :audiobooks, :avg_rating
  end
end
