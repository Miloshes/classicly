class CreateHighlightNotes < ActiveRecord::Migration
  def self.up
    create_table :highlight_notes do |t|
      t.string  :content
      t.string  :noteable_type
      t.integer :noteable_id
      t.integer :login_id
      t.integer :fb_connect_id
      t.timestamps
    end
  end

  def self.down
    drop_table :highlight_notes
  end
end
