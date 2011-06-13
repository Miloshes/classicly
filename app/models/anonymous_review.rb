class AnonymousReview < ActiveRecord::Base
  belongs_to :reviewable, :polymorphic => true

  validates :rating, :presence => true, :numericality => true
  
  def self.create_or_update_from_ios_client_data(data)
    # == fetch the reviewable
    if data['book_id']
      reviewable = Book.find(data['book_id'].to_i)
    else
      reviewable = Audiobook.find(data['audiobook_id'].to_i)
    end

    return nil if reviewable.blank?
    
    new_timestamp = Time.parse(data['timestamp'])
  
    review_conditions = {
        :ios_device_id => data['device_id'],
        :reviewable    => reviewable
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
  
  def convert_to_normal_review
    login = Login.where(:ios_device_id => self.ios_device_id).first()
    
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
