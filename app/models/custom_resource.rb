class CustomResource < ActiveRecord::Base
  belongs_to :blog_post
  
  has_attached_file :image,
                    :styles => { :medium => "300x300>", :thumb => "100x100>" },
                    :storage => Rails.env.development? ? :filesystem : :s3,
                    :s3_credentials => {:access_key_id => APP_CONFIG['amazon']['access_key'],
                                        :secret_access_key => APP_CONFIG['amazon']['secret_key']
                                        },
                    :s3_permissions => 'public-read',
                    :bucket => APP_CONFIG['buckets']['blog_images'],
                    :path => ":rails_root/public:url"
                    
end
