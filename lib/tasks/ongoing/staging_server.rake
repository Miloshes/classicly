require "rest_client"
include AWS::S3

class StagingServerMigrator
  S3_BUCKET_NAME         = APP_CONFIG["buckets"]["staging_to_production_migration"]
  S3_TIMESTAMP_FILE      = "last_export_timestamp.yml" 
  S3_ACKNOWLEDGMENT_FILE = "import_happened"
  S3_USER_DATA_FILE      = "export_data.yml"

  attr_accessor :last_export_timestamp

  def initialize
    create_s3_bucket
  end

  def create_s3_bucket
    Bucket.create(APP_CONFIG["buckets"]["staging_to_production_migration"])
  end

  def last_export_timestamp
    return @last_export_timestamp if @last_export_timestamp.is_a? Time

    timestamp_exists = S3Object.exists?(S3_TIMESTAMP_FILE, S3_BUCKET_NAME)

    if timestamp_exists
      timestamp_data = S3Object.value(S3_TIMESTAMP_FILE, S3_BUCKET_NAME)

      timestamp = YAML.load(timestamp_data)
    else
      timestamp = Time.parse("2001-01-01")

      S3Object.store(S3_TIMESTAMP_FILE, timestamp.to_yaml, S3_BUCKET_NAME)
    end

    @last_export_timestamp = timestamp

    return @last_export_timestamp
  end

  def acknowledgment_file_exists?
    S3Object.exists?(S3_ACKNOWLEDGMENT_FILE, S3_BUCKET_NAME)
  end

  def remove_acknowledgment_file
    S3Object.delete(S3_ACKNOWLEDGMENT_FILE, S3_BUCKET_NAME)
  end

  def upload_user_data
    user_data = gather_all_user_data

    S3Object.store(S3_USER_DATA_FILE, user_data.to_yaml, S3_BUCKET_NAME)
  end

  def update_last_export_timestamp
    S3Object.store(S3_TIMESTAMP_FILE, Time.now.to_yaml, S3_BUCKET_NAME)
  end

  def notify_production_server
    data = {
      "action"    => "import_user_data_from_staging_server",
      "timestamp" => Time.now
    }
    
    response = RestClient.post('http://localhost:3000/web_api', :json_data => data.to_json)
  end

  def gather_all_user_data
    gathered_objects = []

    # gather users and their reviews
    Login.where(:created_at.gt => last_export_timestamp).all.each do |login|
      gathered_objects << login

      login.reviews.each do |review|
        gathered_objects << review
      end
    end

    # gather ios devices
    IosDevice.where(:updated_at.gt => last_export_timestamp).all do |ios_device|
      gathered_objects << ios_device
    end

    # gather anonymous reviews

    AnonymousReview.where(:created_at.gt => last_export_timestamp).all do |anonymous_review|
      gathered_objects << anonymous_review
    end

    puts gathered_objects.inspect

    return gathered_objects
  end

  def export_and_upload_user_content
    # S3Object.store(S3_ACKNOWLEDGMENT_FILE, "", S3_BUCKET_NAME)
    # return

    if acknowledgment_file_exists?
      remove_acknowledgment_file
    else
      # the production server couldn't import the data - bailing out
      return
    end

    upload_user_data
    update_last_export_timestamp
    notify_production_server
  end

end

namespace :staging_server do
  # Logins (ID DEPENDENCY): Reviews, IosDevices
  # No ID dependency:  Anonymous_Reviews (it depends on ios device id)

  desc "Reads in unexported users and all the content they created, uploads result YAML file to S3"
  task :export_user_content => :environment do
    migrator = StagingServerMigrator.new
    migrator.export_and_upload_user_content
  end
  
end