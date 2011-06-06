class Review < ActiveRecord::Base
  belongs_to :reviewable, :polymorphic => true
  belongs_to :reviewer, :class_name => 'Login', :foreign_key => 'login_id'

  validates_presence_of :content
  validates :rating, :presence => true, :numericality => true

  # after_create :deliver_review_created_notification_to_flowdock

  def self.create_or_update_from_ios_client_data(data)
    # == fetch the reviewable
    if data['book_id']
      reviewable = Book.find(data['book_id'].to_i)
    else
      reviewable = Audiobook.find(data['audiobook_id'].to_i)
    end

    # == fetch the user
    
    # API version 1.1: user registration API call with facebook connect ID is required before submitting a review    
    # API version 1.2: users can send reviews without registration, they'll be identified by device ID
    
    if data['structure_version'] == '1.1'
      logger.info(" -- API 1.1: fetching login via facebook connect ID")

      login = Login.where(:fb_connect_id => data['user_fbconnect_id'].to_s).first()
    elsif data['structure_version'] == '1.2'
      logger.info(" -- API 1.2")
      
      # 1. we get fb_connect_id: it's an existing user
      if data['user_fbconnect_id']
        logger.info(" -- got facebook connect ID")
        login = Login.where(:fb_connect_id => data['user_fbconnect_id'].to_s).first()        
      else
      # 2. no fb_connect_id: we setup a temporary login that holds the device_id
      # later we connect it to the facebook ID when the user registers
        logger.info(" -- no facebook connect ID")
        login = Login.where(:ios_device_id => data['device_id'].to_s).first()
      end
    end
    
    return nil if login.blank? || reviewable.blank?
    
    new_timestamp = Time.parse(data['timestamp'])
    
    review_conditions = {
        :login_id      => login.id,
        :reviewable    => reviewable,
        :fb_connect_id => login.fb_connect_id
      }

    new_review_data = {
        :content    => data['content'],
        :rating     => data['rating'],
        :created_at => new_timestamp
      }
    
    review = self.where(review_conditions).first()
    
    if review
      review.update_attributes(new_review_data) unless new_timestamp < review.created_at
    else
      self.create(review_conditions.merge new_review_data)
    end
  end

  def deliver_review_created_notification_to_flowdock
    ReviewMailer.deliver_notification_on_flowdock self
  end

end
