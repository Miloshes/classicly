class AddNewColumnsToLogin < ActiveRecord::Migration
  def self.up
    add_column :logins, :terms_of_service, :boolean, :default => false, :null => :false
    add_column :logins, :hashed_password, :string
    add_column :logins, :salt, :string
    add_column :logins, :twitter_name, :string
  end

  def self.down
    remove_column :logins, :twitter_name
    remove_column :logins, :salt
    remove_column :logins, :hashed_password
    remove_column :logins, :terms_of_service
  end
end