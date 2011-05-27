class AddFirstLineIndentToBookPages < ActiveRecord::Migration
  def self.up
    change_table :book_pages do |t|
      unless column_exists? :first_line_indent
        t.boolean :first_line_indent, :default => false, :null => false
      end
    end
  end

  def self.down
    remove_column :book_pages, :first_line_indent
  end
end