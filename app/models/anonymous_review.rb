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
  
end
