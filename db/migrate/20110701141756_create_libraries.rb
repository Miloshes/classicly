class CreateLibraries < ActiveRecord::Migration
  def self.up
    create_table :libraries do |t|
      t.integer :login_id
      t.integer :total_pages_read, :default => 0, :null => false
      t.integer :books_downloaded, :default => 0, :null => false
    end
  end

  def self.down
    drop_table :libraries
  end
end
