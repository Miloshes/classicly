class AddDescriptionsToAudiobooks < ActiveRecord::Migration
  def self.up
    add_column :audiobooks, :description, :text
  end

  def self.down
    remove_column :audiobooks, :description
  end
end