class AddForceRerenderToBookPages < ActiveRecord::Migration
  def self.up
    add_column :book_pages, :force_rerender, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :book_pages, :force_rerender
  end
end