class AddFirstLineIndentToBookPages < ActiveRecord::Migration
  def self.up
    add_column :book_pages, :first_line_indent, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :book_pages, :first_line_indent
  end
end