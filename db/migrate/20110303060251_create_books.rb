class CreateBooks < ActiveRecord::Migration
  def self.up
    create_table :books do |t|
      t.text     "title"
      t.integer  "author_id"
      t.string   "language"
      t.integer  "published"
      t.boolean  "blessed",                        :default => false, :null => false
      t.integer  "custom_cover_id"
      t.text     "description"

      t.timestamps
    end
  end

  def self.down
    drop_table :books
  end
end
