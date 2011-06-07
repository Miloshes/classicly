class AddIsRenderedForOnlineReadingToBooks < ActiveRecord::Migration
  def self.up
    add_column :books, :is_rendered_for_online_reading, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :books, :is_rendered_for_online_reading
  end
end