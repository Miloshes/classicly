class CreateAudiobookNarrators < ActiveRecord::Migration
  unless table_exists? :audiobook_narrators
    def self.up
      create_table :audiobook_narrators do |t|
        t.string :name
      end
    end
  end

  def self.down
    drop_table :audiobook_narrators
  end
end
