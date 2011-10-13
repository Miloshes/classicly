class CreateIosDevices < ActiveRecord::Migration
  def self.up
    create_table :ios_devices do |t|
      t.integer :user_id
      t.string :ss_udid
      t.string :original_udid
      t.datetime :updated_at
    end
    
    Login.find_each do |login|
      IosDevice.create(:user => login, :ss_udid => login.ios_device_ss_id, :original_udid => login.ios_device_id)
    end
    
    remove_column :logins, :ios_device_id
    remove_column :logins, :ios_device_ss_id
  end

  def self.down
    drop_table :ios_devices
    
    add_column :logins, :ios_device_id, :string
    add_column :logins, :ios_device_ss_id, :string
  end
end
