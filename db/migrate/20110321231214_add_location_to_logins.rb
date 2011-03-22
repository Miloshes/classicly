class AddLocationToLogins < ActiveRecord::Migration
  def self.up
    add_column :logins, :location_city, :string
    add_column :logins, :location_state, :string
    add_column :logins, :location_country, :string
  end

  def self.down
    remove_column :logins, :location_country
    remove_column :logins, :location_state
    remove_column :logins, :location_city
  end
end
