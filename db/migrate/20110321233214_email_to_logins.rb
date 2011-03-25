class EmailToLogins < ActiveRecord::Migration
  def self.up
    add_column :logins, :email, :string
  end

  def self.down
    remove_column :logins, :email
  end
end
