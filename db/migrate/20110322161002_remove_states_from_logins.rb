class RemoveStatesFromLogins < ActiveRecord::Migration
  def self.up
    remove_column :logins, :location_state
  end

  def self.down
    add_column :logins, :location_state, :string
  end
end