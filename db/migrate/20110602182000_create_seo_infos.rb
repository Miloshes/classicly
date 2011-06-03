class CreateSeoInfos < ActiveRecord::Migration
  def self.up
    create_table :seo_infos do |t|
      t.integer :infoable_id
      t.string :meta_description
      t.string :title
      t.string :og_title
      t.string :og_image
      t.string :og_description

      t.timestamps
    end
  end

  def self.down
    drop_table :seo_infos
  end
end
