class AddForceRerenderToBookPages < ActiveRecord::Migration
  def self.up
    unless column_exists? :book_pages, :force_renderer
      add_column :book_pages, :force_rerender, :boolean, :default => false, :null => false
    end
  end

  def self.down
    remove_column :book_pages, :force_rerender
  end
end