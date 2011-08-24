class AddRatingToReviews < ActiveRecord::Migration
  def self.up
    add_column :reviews, :rating, :integer, :default => 0 
  end

  def self.down
    remove_column :reviews, :rating
  end
end
