class AddImageUrlToLogins < ActiveRecord::Migration
  def self.up
    add_column :logins, :image_url, :string
  end

  def self.down
    remove_column :logins, :image_url
  end
end
