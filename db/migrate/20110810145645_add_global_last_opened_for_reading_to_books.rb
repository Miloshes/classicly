class AddGlobalLastOpenedForReadingToBooks < ActiveRecord::Migration
  def self.up
    add_column :books, :global_last_opened, :datetime
  end

  def self.down
    remove_column :books, :global_last_opened
  end
end