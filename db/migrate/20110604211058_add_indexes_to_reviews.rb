class AddIndexesToReviews < ActiveRecord::Migration
  def self.up
    add_index :reviews, [:reviewable_id, :reviewable_type], :name => 'reviewable_id_reviewable_type_index_for_reviews'
  end

  def self.down
    remove_index :reviews, :name => 'reviewable_id_reviewable_type_index_for_reviews'
  end
end
