class ChangeFacebookIdToUserIdForReviews < ActiveRecord::Migration
  def self.up
    change_table :reviews do |t|
      t.string :user_id
    end
  end

  def self.down
    change_table :reviews do |t|
      t.remove :user_id
    end
  end
end
