class AddFormatToSeoDefaults < ActiveRecord::Migration
  def self.up
    add_column :seo_defaults, :format, :string
  end

  def self.down
    remove_column :seo_defaults, :format
  end
end
