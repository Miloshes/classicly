class CreateAudiobookNarrators < ActiveRecord::Migration
  def self.up
    create_table :audiobook_narrators do |t|
      t.string :name
    end
  end

  def self.down
    drop_table :audiobook_narrators
  end
end
