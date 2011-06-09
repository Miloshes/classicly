class CreateAnonymousReviews < ActiveRecord::Migration
  def self.up
    create_table :anonymous_reviews do |t|
      t.integer :reviewable_id
      t.string :reviewable_type
      t.text :content
      t.integer :rating
      t.datetime :created_at
      t.string :ios_device_id
    end
  end

  def self.down
    drop_table :anonymous_reviews
  end
end
