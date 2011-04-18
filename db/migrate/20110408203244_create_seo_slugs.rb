class CreateSeoSlugs < ActiveRecord::Migration
  def self.up
    create_table :seo_slugs do |t|
      t.integer :seoable_id
      t.string :seoable_type
      t.string :slug
      t.string :format
    end
    add_index :seo_slugs, :slug
  end

  def self.down
    drop_table :seo_slugs
  end
end
