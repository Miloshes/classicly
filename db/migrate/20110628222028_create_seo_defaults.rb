class CreateSeoDefaults < ActiveRecord::Migration
  def self.up
    create_table :seo_defaults do |t|
      t.string :object_type
      t.string :object_attribute
      t.string :default_value

      t.timestamps
    end
  end

  def self.down
    drop_table :seo_defaults
  end
end
