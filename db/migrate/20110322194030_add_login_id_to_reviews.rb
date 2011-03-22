class AddLoginIdToReviews < ActiveRecord::Migration
  def self.up
    add_column :reviews, :login_id, :integer
  end

  def self.down
    remove_column :reviews, :login_id
  end
end
