class AddInfoableTypeToSeoInfos < ActiveRecord::Migration
  def self.up
    add_column :seo_infos, :infoable_type, :string
  end

  def self.down
    remove_column :seo_infos, :infoable_type
  end
end
