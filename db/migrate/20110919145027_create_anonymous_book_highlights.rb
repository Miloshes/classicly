class CreateAnonymousBookHighlights < ActiveRecord::Migration
  def self.up
    create_table :anonymous_book_highlights do |t|
      t.integer :first_character
      t.integer :last_character
      t.text :content
      t.string :ios_device_id
      t.datetime :created_at
      t.text :note
      t.integer :book_id
    end
  end

  def self.down
    drop_table :anonymous_book_highlights
  end
end
