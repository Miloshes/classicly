class AddAvailabilityFieldToBooks < ActiveRecord::Migration
  def self.up
    add_column :books, :available, :boolean, :default => true
  end

  def self.down
    remove_column :books, :available
  end
end
