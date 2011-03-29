class RemoveTitlesFromReviews < ActiveRecord::Migration
  def self.up
    remove_column :reviews, :title
  end

  def self.down
    add_column :reviews, :title, :string
  end
end
