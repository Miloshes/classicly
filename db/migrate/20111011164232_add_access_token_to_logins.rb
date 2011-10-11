class AddAccessTokenToLogins < ActiveRecord::Migration
  def self.up
    add_column :logins, :access_token, :string
  end

  def self.down
    remove_column :logins, :access_token
  end
end
