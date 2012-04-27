require 'csv'
include AWS::S3

namespace :export do
  APP_CONFIG = YAML.load_file("config/app_config.yml")
  
  AWS::S3::Base.establish_connection! access_key_id: APP_CONFIG['amazon']['access_key'], secret_access_key: APP_CONFIG['amazon']['secret_key']
  bucket_name = 'spreadsong-classicly-export'
  bucket = begin
    Bucket.find bucket_name
  rescue AWS::S3::NoSuchBucket
    Bucket.create bucket_name
    retry
  end

  namespace :emails do

    desc 'Generate CSV'
    task :csv => :environment do
      string = CSV.generate do |csv|
        csv << ['Email Address', 'First Name', 'Last Name']  
        Login.where(mailing_enabled: true).all.each do |u|
          # next unless u.email =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
          csv << [u.email, u.first_name, u.last_name]
        end
      end
      object = "email-export-#{Time.now.to_i}.csv"
      S3Object.store(object, string, bucket_name, access: :public_read)
      bucket[object].url(authenticated: false, expires_in: 3600 * 24)
    end
    
    desc 'Clean up exports'
    task clean: :environment do
      Bucket.delete bucket_name, force: true
    end
    
    desc 'List exports'
    task list: :environment do
      bucket.objects.each {|o| puts o.url(authenticated: false) }
    end
  end

end
