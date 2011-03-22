class AddAverageRatingToBooks < ActiveRecord::Migration
  def self.up
    add_column :books, :avg_rating, :integer, :default => 0
  end

  def self.down
    remove_column :books, :avg_rating
  end
end
