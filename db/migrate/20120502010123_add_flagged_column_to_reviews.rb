class AddFlaggedColumnToReviews < ActiveRecord::Migration
  def self.up
    add_column :reviews, :flagged, :boolean, default: false, null: false
  end
  
  def self.down
    remove_column :reviews, :flagged
  end    
end
