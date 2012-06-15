class AddClientApplicationIdToLogin < ActiveRecord::Migration
  def self.up
  	add_column :logins, :client_application_id, :integer
  	add_index :logins, :client_application_id
  end

  def self.down
  	remove_index :logins, :client_application_id
  	remove_column :logins, :client_application_id
  end
end
