class AddFeaturedColumnToReviews < ActiveRecord::Migration
  def self.up
    add_column :reviews, :featured, :boolean, default: false, null: false
  end
  
  def self.down
    remove_column :reviews, :featured
  end    
end
