class RemoveRatingFromReviews < ActiveRecord::Migration
  def self.up
    change_table :reviews do|t|
      t.remove :rating
    end
  end

  def self.down
    change_table :reviews do|t|
      t.integer :rating, :default => 1
    end
  end
end
