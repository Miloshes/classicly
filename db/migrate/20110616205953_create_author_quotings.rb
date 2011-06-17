class CreateAuthorQuotings < ActiveRecord::Migration
  def self.up
    create_table :author_quotings do |t|
      t.integer :blog_post_id
      t.integer :author_id
      t.text :quoted_text

      t.timestamps
    end
    add_index :author_quotings, :author_id
    add_index :author_quotings, :blog_post_id
  end

  def self.down
    drop_table :author_quotings
  end
end
