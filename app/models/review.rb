class Review < ActiveRecord::Base
  belongs_to :reviewable, :polymorphic => true
  belongs_to :reviewer, :class_name => 'User', :foreign_key => 'user_id'
  validates :title, :presence => true
  validates :content, :presence => true
  validates :rating, :presence => true, :numericality => true
  
  def self.create_or_update_from_ios_client_data(data)
    book = Book.find(data['book_id'])
    user = Login.where(:uid => data['user_fbconnect_id'], :provider => 'facebook').first().user
    
    review_conditions = {
        :reviewable_id => book.id,
        :fb_connect_id => user.uid_for(:facebook)
      }

    new_review_data = {
        :title      => data['title'],
        :content    => data['content'],
        :rating     => data['rating'],
        :created_at => Time.parse(data['timestamp'])
      }
    
    review = self.where(review_conditions).first()
    
    if review
      review.update_attributes(new_review_data)
    else
      self.create(review_conditions.merge new_review_data)
    end
  end
end
