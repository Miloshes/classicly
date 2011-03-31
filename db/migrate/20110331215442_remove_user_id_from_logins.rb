class RemoveUserIdFromLogins < ActiveRecord::Migration
  def self.up
    remove_column :logins, :user_id
  end

  def self.down
    add_column :logins, :user_id, :integer
  end
end
