class CreateClientApplications < ActiveRecord::Migration
  def self.up
    create_table :client_applications do |t|
      t.string :application_id
      t.string :platform
      t.text :description
      t.timestamps
    end

  end

  def self.down
    drop_table :client_applications
  end
end
