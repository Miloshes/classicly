class AddFirstAndLastNamesToLogins < ActiveRecord::Migration
  def self.up
    add_column :logins, :first_name, :string
    add_column :logins, :last_name, :string
  end

  def self.down
    remove_column :logins, :last_name
    remove_column :logins, :first_name
  end
end
