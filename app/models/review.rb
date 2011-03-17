class Review < ActiveRecord::Base
  belongs_to :reviewable, :polymorphic => true
  belongs_to :reviewer, :class_name => 'User', :foreign_key => 'user_id'
  validates :title, :presence => true
  validates :content, :presence => true
  validates :rating, :presence => true, :numericality => true
  
  def self.create_from_ios_client_data(data)
    self.create(
      :reviewable    => Book.find(data['book_id']),
      :fb_connect_id => data['user_fbconnect_id'],
      :title         => data['title'],
      :content       => data['content'],
      :rating        => data['rating'],
      :created_at    => Time.parse(data['timestamp'])
    )
  end
end
