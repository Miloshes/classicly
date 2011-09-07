class CreateQuotes < ActiveRecord::Migration
  def self.up
    create_table :quotes do |t|
      t.integer :collection_id
      t.text :content
      t.integer :author_id

      t.timestamps
    end
  end

  def self.down
    drop_table :quotes
  end
end
