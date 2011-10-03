class AnonymousReview < ActiveRecord::Base
  belongs_to :reviewable, :polymorphic => true

  validates :rating, :presence => true, :numericality => true
  
  def self.create_or_update_from_ios_client_data(data)
    # == fetch the reviewable
    if data["book_id"]
      reviewable = Book.find(data["book_id"].to_i)
    else
      reviewable = Audiobook.find(data["audiobook_id"].to_i)
    end

    return nil if reviewable.blank?
    
    new_timestamp = Time.parse(data["timestamp"])
  
    review_conditions = {
        :ios_device_ss_id => data["device_ss_id"],
        :reviewable       => reviewable
      }

    review_conditions_with_old_udid = {
        :ios_device_id => data["device_id"],
        :reviewable    => reviewable
      }
    
    # try to find the review with our UDID replacement
    review = self.where(review_conditions).first()
    
    # no review - try to look it up by the original UDID
    if review.blank?
      review = self.where(review_conditions_with_old_udid).first()
      
      # we got the review, update to use the UDID replacement
      if review
        review.update_attrbiutes(:ios_device_ss_id => data["device_ss_id"])
      end
    end
        
    new_review_data = {
        :content       => data["content"],
        :rating        => data["rating"],
        :created_at    => new_timestamp,
        # we're also storing the legacy UDID, just to make sure the old systems still work
        :ios_device_id => data["device_id"]
      }
  
    if review
      review.update_attributes(new_review_data) unless new_timestamp < review.created_at
    else
      self.create(review_conditions.merge new_review_data)
    end
  end
  
  def convert_to_normal_review
    if self.ios_device_ss_id
      login = Login.where(:ios_device_ss_id => self.ios_device_ss_id).first()
    else
      login = Login.where(:ios_device_id => self.ios_device_id).first()
    end
    
    review_conditions = {
      :login_id      => login.id,
      :reviewable    => self.reviewable,
      :fb_connect_id => login.fb_connect_id
    }

    existing_review = Review.where(review_conditions).first()
    
    review_data = {
      :rating     => self.rating,
      :created_at => self.created_at
    }
        
    if existing_review
      successful_update = existing_review.update_attributes(review_data)
      
      self.destroy if successful_update
    else
      new_review = Review.create(review_conditions.merge review_data)
      
      self.destroy if new_review
    end
  end
  
end
