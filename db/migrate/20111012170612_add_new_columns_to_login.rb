class AddNewColumnsToLogin < ActiveRecord::Migration
  def self.up
    add_column :logins, :terms_of_services, :boolean, :default => false, :null => :false
    add_column :logins, :password, :string
    add_column :logins, :twitter_name, :string
  end

  def self.down
    remove_column :logins, :twitter_name
    remove_column :logins, :password
    remove_column :logins, :terms_of_services
  end
end