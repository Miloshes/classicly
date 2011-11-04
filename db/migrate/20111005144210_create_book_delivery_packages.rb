class CreateBookDeliveryPackages < ActiveRecord::Migration
  def self.up
    create_table :book_delivery_packages do |t|
      t.integer :source_user
      
      t.integer :destination_user
      t.string :destination_user_email
      t.string :destination_user_fb_connect_id
      
      t.string :deliverable_type
      t.integer :deliverable_id
      t.text :message
      
      t.timestamps
    end
  end

  def self.down
    drop_table :book_delivery_packages
  end
end
