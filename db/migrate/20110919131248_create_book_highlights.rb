class CreateBookHighlights < ActiveRecord::Migration
  def self.up
    create_table :book_highlights do |t|
      t.integer :first_character
      t.integer :last_character
      t.text :content
      t.string :ios_device_id
      t.datetime :created_at
      t.integer :login_id
      t.text :note
      t.integer :book_id
    end
  end

  def self.down
    drop_table :book_highlights
  end
end
