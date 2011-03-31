class AddAdminToLogins < ActiveRecord::Migration
  def self.up
    add_column :logins, :is_admin, :boolean, :default => false
  end

  def self.down
    remove_column :logins, :is_admin
  end
end
