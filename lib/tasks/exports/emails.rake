require 'csv'
include AWS::S3

namespace :export do
  APP_CONFIG = {amazon: {
    access_key_id: "0MMK343NZCJ3D1CZ8NG2",
    secret_access_key: "DuArKmSc2MHk2aT976tQaD3Kvr9iyQwbX8DKMGWh",
  }}

  AWS::S3::Base.establish_connection! APP_CONFIG[:amazon]
  bucket_name = 'spreadsong-classicly-export'
  bucket = begin
    Bucket.find bucket_name
  rescue AWS::S3::NoSuchBucket
    Bucket.create bucket_name
  end

  namespace :emails do

    desc 'Test generated sitemap'
    task :csv => :environment do
      string = CSV.generate do |csv|
        csv << ['Email Address', 'First Name', 'Last Name']  
        Login.where(mailing_enabled: true).all.each do |u|
          # next unless u.email =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
          csv << [u.email, u.first_name, u.last_name]
        end
      end
      S3Object.store("email-export-#{RAILS_ENV}.csv", string, bucket_name, access: :public_read)
      bucket.objects.each {|o| puts o.url(authenticated: false, expires_in: 3600 * 12) }
    end
  end

end
