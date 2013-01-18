require "rest_client"
include AWS::S3

class StagingToProductionMigrator
  S3_BUCKET_NAME         = APP_CONFIG["buckets"]["staging_to_production_migration"]
  S3_TIMESTAMP_FILE      = "last_export_timestamp.yml" 
  S3_ACKNOWLEDGMENT_FILE = "import_happened"
  S3_USER_DATA_FILE      = "export_data.yml"

  attr_accessor :last_export_timestamp

  def initialize
    AWS::S3::Base.establish_connection!(
        :access_key_id     => APP_CONFIG["amazon"]["access_key"],
        :secret_access_key => APP_CONFIG["amazon"]["secret_key"]
      )

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

  def read_exported_user_data
     data = S3Object.value(S3_USER_DATA_FILE, S3_BUCKET_NAME)   

     return YAML.load(data)
  end

  def update_last_export_timestamp
    S3Object.store(S3_TIMESTAMP_FILE, Time.now.to_yaml, S3_BUCKET_NAME)
  end

  def notify_production_server
    data = {
      "action"            => "import_user_data_from_staging_server",
      "timestamp"         => Time.now,
      "structure_version" => "1.4"
    }

    response = RestClient.post(
        "https://secure.classicly.com/web_api",
        :json_data     => data.to_json,
        :api_key       => APP_CONFIG["api_key"],
        :api_signature => Digest::MD5.hexdigest(data.to_json + APP_CONFIG["api_secret"])
      )
  end

  def gather_all_user_data
    all_data = {
      # for storing the user and it's associated objects
      :user_objects             => [],
      # anonymous reviews are associated through device UDID, not the primary key of ios_devices
      :anonymous_review_objects => []
    }

    # gather users, their reviews and ios devices
    Login.where(:created_at.gt => last_export_timestamp).all.each do |login|
      data_for_one_user = {
        :user        => login.attributes,
        :reviews     => [],
        :ios_devices => []
      }

      login.reviews.each { |review| data_for_one_user[:reviews] << review.attributes }
      login.ios_devices.each { |ios_device| data_for_one_user[:ios_devices] << ios_device.attributes }

      all_data[:user_objects] << data_for_one_user
    end

    # gather anonymous reviews
    AnonymousReview.where(:created_at.gt => last_export_timestamp).all.each do |anonymous_review|
      all_data[:anonymous_review_objects] << anonymous_review.attributes
    end

    return all_data
  end

  def write_data_into_database(data_to_import)
    # == Import the users and their associated objects
    data_to_import[:user_objects].each do |user_object|
      user_attributes = user_object[:user]
      user_attributes.delete("id")

      login = Login.create(user_attributes)

      # importing the reviews while associating it with the user
      user_object[:reviews].each do |review_attributes|
        review_attributes.delete("id")
        review_attributes[:login_id] = login.id

        Review.create(review_attributes)
      end

      # importing the ios devices while associating it with the user
      user_object[:ios_devices].each do |ios_device_attributes|
        ios_device_attributes.delete("id")
        ios_device_attributes[:user_id] = login.id

        IosDevice.create(ios_device_attributes)
      end
    end

    # == Import the anonymous reviews which doesn't have dependencies
    data_to_import[:anonymous_review_objects].each do |anonymous_review_attributes|
      anonymous_review_attributes.delete("id")

      AnonymousReview.create(anonymous_review_attributes)
    end
  end

  def export_and_upload_user_content
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

  def import_user_content
    # no new exported data, bailing out
    return if acknowledgment_file_exists?

    data_to_import = read_exported_user_data

    write_data_into_database(data_to_import)
    create_acknowledgment_file
  end

  def create_acknowledgment_file
    S3Object.store(S3_ACKNOWLEDGMENT_FILE, "", S3_BUCKET_NAME)
  end

  def setup_for_first_run
    # We place the acknowledgment file into the bucket so the first export can happen
    create_acknowledgment_file
  end

end