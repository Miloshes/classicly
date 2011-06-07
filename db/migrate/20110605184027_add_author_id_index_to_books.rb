class AddAuthorIdIndexToBooks < ActiveRecord::Migration
  def self.up
    add_index :books, :author_id
  end

  def self.down
    remove_index :books, :author_id
  end
end
