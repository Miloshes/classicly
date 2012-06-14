class AddMailchimpSubscribedToLogins < ActiveRecord::Migration
  def self.up
    add_column :logins, :mailchimp_subscribed, :boolean, :default => false
  end

  def self.down
    remove_column :logins, :mailchimp_subscribed
  end
end
