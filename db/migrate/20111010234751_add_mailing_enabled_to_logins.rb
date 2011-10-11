class AddMailingEnabledToLogins < ActiveRecord::Migration

  def self.up
    add_column :logins, :mailing_enabled, :boolean, :default => true
  end

  def self.down
    remove_column :logins, :mailing_enabled
  end

end
