class AddPasswordResetToLogins < ActiveRecord::Migration
  def self.up
    add_column :logins, :password_reset_token, :string
    add_column :logins, :password_reset_sent_at, :datetime
  end

  def self.down
    remove_column :logins, :password_reset_sent_at
    remove_column :logins, :password_reset_token
  end
end
