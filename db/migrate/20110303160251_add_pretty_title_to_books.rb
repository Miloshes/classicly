class AddPrettyTitleToBooks < ActiveRecord::Migration
  def self.up
    add_column :books, :pretty_title, :string
    
    Book.all.each do |book|
      lowercase_title = book.title.downcase
      
      if lowercase_title.include? ', the'
        new_title = "The " + book.title[0...-5]
      elsif lowercase_title.include? ', a'
        new_title = "A " + book.title[0...-3]
      elsif lowercase_title.include? ', an'
        new_title = "An " + book.title[0...-4]
      end
      
      book.pretty_title = new_title[0,255]
      book.save
    end
  end

  def self.down
    remove_column :books, :pretty_title
  end
end