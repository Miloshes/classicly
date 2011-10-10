class CreateBookDeliveryPackages < ActiveRecord::Migration
  def self.up
    create_table :book_delivery_packages do |t|
      t.string :source_user
      t.string :destination_user
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
