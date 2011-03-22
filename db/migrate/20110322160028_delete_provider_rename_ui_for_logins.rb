class DeleteProviderRenameUiForLogins < ActiveRecord::Migration
  def self.up
    change_table :logins do|t|
      t.remove :provider
      t.remove :uid
      t.string :fb_connect_id
    end
  end

  def self.down
    change_table :logins do |t|
      t.remove :fb_connect_id
      t.string :uid
      t.string :provider
    end
  end
end
