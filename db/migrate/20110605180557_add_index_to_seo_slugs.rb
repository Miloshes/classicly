class AddIndexToSeoSlugs < ActiveRecord::Migration
  def self.up
    add_index :seo_slugs, [:seoable_id, :seoable_type], :name => 'seoable_id_seoable_type_index_for_seo_slugs'
  end

  def self.down
    remove_index :seo_slugs, :name => 'seoable_id_seoable_type_index_for_seo_slugs'
  end
end
