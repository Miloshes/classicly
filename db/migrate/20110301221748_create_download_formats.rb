class CreateDownloadFormats < ActiveRecord::Migration
  def self.up
    create_table :download_formats do |t|
      t.integer :book_id
      # 'txt.zip', 'pdf, 'rtf', 'azw', etc
      t.string :format
      # NOTE:
      # Eventually we'll be generating the books in all the formats from our updated book collection.
      # In the meantime we're using what we downloaded from other sites and mark it with a 'legacy' flag.
      # 'txt.zip' is the base format that we'll be using to re-generate the books.
      t.boolean :legacy, :default => true
      t.string :download_status, :default => 'never tried'
    end
  end

  def self.down
    drop_table :download_formats
  end
end
