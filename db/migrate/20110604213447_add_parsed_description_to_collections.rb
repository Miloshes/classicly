class AddParsedDescriptionToCollections < ActiveRecord::Migration
  def self.up
    add_column :collections, :parsed_description, :text
  end

  def self.down
    remove_column :collections, :parsed_description
  end
end