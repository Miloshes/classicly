class ChangeUserToLoginAssocForReviews < ActiveRecord::Migration
  def self.up
    change_table :reviews do|t|
      t.remove :user_id
      t.integer :login_id
    end
  end

  def self.down
    change_table :reviews do|t|
      t.remove :login_id
      t.integer :user_id
    end
  end
end
