class AddUnregisteredAndLastAccessedToLibraries < ActiveRecord::Migration
  def self.up
    add_column :libraries, :unregistered, :boolean, :default => true, :null => false
    add_column :libraries, :last_accessed, :datetime
  end

  def self.down
    remove_column :libraries, :last_accessed
    remove_column :libraries, :unregistered
  end
end