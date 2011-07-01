class AddCollectionTypeToSeoDefaults < ActiveRecord::Migration
  def self.up
    add_column :seo_defaults, :collection_type, :string
  end

  def self.down
    remove_column :seo_defaults, :collection_type
  end
end
