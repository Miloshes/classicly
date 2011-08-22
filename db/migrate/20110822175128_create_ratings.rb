class CreateRatings < ActiveRecord::Migration
  def self.up
    create_table :ratings do |t|
      t.string :fb_connect_id
      t.integer :login_id
      t.integer :rate
      t.integer :rateable_id

      t.timestamps
    end
  end

  def self.down
    drop_table :ratings
  end
end
