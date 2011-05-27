class AddFirstLineIndentToBookPages < ActiveRecord::Migration
  def self.up
    unless column_exists? :book_pages, :first_line_indent
      add_column :book_pages, :first_line_indent, :boolean, :default => false, :null => false
    end
  end

  def self.down
    remove_column :book_pages, :first_line_indent
  end
end