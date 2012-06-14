namespace :mailchimp do

  desc 'sync subscribe'
  task :sync => :environment do
    require 'mailchimp'
    
    mc = MailChimp.new
    
    puts "Batch subscribing users (only update subscribed one and subscribe new ones, unsubscribed users won't be subscribed again)"
    mc.batch(:subscribe) { Login.where mailing_enabled: true, mailchimp_subscribed: false }
    
  end   
end
