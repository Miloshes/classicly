class AddAudioCollectionIdToCollections < ActiveRecord::Migration
  def self.up
    add_column :collections, :audio_collection_id, :integer
  end

  def self.down
    remove_column :collections, :audio_collection_id
  end
end
