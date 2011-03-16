class CreateReviews < ActiveRecord::Migration
  def self.up
    create_table :reviews do |t|
      t.string :fb_connect_id
      t.integer :reviewable_id
      t.string :reviewable_type
      t.string :title
      t.text :content
      t.integer :rating
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :reviews
  end
end
