class AddEditorsChoiceColumnToReviews < ActiveRecord::Migration
  def self.up
    add_column :reviews, :editors_choice, :boolean, default: false, null: false
  end
  
  def self.down
    remove_column :reviews, :editors_choice
  end    
end
