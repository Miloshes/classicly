class AddIosDeviceIdToLogins < ActiveRecord::Migration
  def self.up
    add_column :logins, :ios_device_id, :string
  end

  def self.down
    remove_column :logins, :ios_device_id
  end
end