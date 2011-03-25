class RemoveImageUrlFromLogins < ActiveRecord::Migration
  def self.up
    remove_column :logins, :image_url
  end

  def self.down
    add_column :logins, :image_url, :string
  end
end
