class AddIosDeviceSpreadsongIdToModels < ActiveRecord::Migration
  def self.up
    add_column :anonymous_reviews, :ios_device_ss_id, :string
    add_column :anonymous_book_highlights, :ios_device_ss_id, :string
    add_column :logins, :ios_device_ss_id, :string
    
    add_index :anonymous_reviews, :ios_device_ss_id
    add_index :anonymous_book_highlights, :ios_device_ss_id
  end

  def self.down
    remove_column :logins, :ios_device_ss_id
    remove_column :anonymous_book_highlights, :ios_device_ss_id
    remove_column :anonymous_reviews, :ios_device_ss_id
    
    remove_index :anonymous_reviews, :ios_device_ss_id
    remove_index :anonymous_book_highlights, :ios_device_ss_id
  end
end