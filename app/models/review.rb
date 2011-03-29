class Review < ActiveRecord::Base
  belongs_to :reviewable, :polymorphic => true
  belongs_to :reviewer, :class_name => 'Login', :foreign_key => 'login_id'

  validates :content, :presence => true
  validates :rating, :presence => true, :numericality => true
  
  def self.create_or_update_from_ios_client_data(data)
    book  = Book.find(data['book_id'].to_i)
    login = Login.where(:fb_connect_id => data['user_fbconnect_id'].to_s).first()
    
    review_conditions = {
        :login_id      => login.id,
        :reviewable    => book,
        :fb_connect_id => login.fb_connect_id
      }

    new_review_data = {
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
