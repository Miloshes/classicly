class CreateAudiobookChapters < ActiveRecord::Migration
  def self.up
    create_table :audiobook_chapters do |t|
      t.integer :audiobook_id
      t.string :title
      t.integer :duration
      t.string :download_link
      t.integer :audiobook_narrator_id
    end
  end

  def self.down
    drop_table :audiobook_chapters
  end
end
