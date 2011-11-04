class CreateUserUploadedContents < ActiveRecord::Migration
  def self.up
    create_table :user_uploaded_contents do |t|
      t.text :original_filename
      t.string :mime_type
      t.integer :login_id
      t.datetime :created_at

      t.timestamps
    end
  end

  def self.down
    drop_table :user_uploaded_contents
  end
end
