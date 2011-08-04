class CreateLibraryAudiobooks < ActiveRecord::Migration
  def self.up
    create_table :library_audiobooks do |t|
      t.integer :library_id
      t.integer :audiobook_id
      
      t.datetime :last_opened
      t.integer :listening_position
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :library_audiobooks
  end
end
