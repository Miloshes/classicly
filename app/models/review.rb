class Review < ActiveRecord::Base
  scope :with_content, -> { where.not(:content => "") }
  scope :most_recent, -> { order("created_at DESC") }
  scope :featured, -> { where(featured: true) }

  belongs_to :reviewable, :polymorphic => true
  belongs_to :reviewer, :class_name => "Login", :foreign_key => "login_id"

  validates :reviewer, :presence => true
  validates :reviewable, :presence => true
  validates :rating, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 5 }

  before_validation :sanitize_rating

  def self.create_or_update_from_ios_client_data(data)
    # == fetch the reviewable
    if data["book_id"]
      reviewable = Book.find(data["book_id"].to_i)
    else
      reviewable = Audiobook.find(data["audiobook_id"].to_i)
    end

    return nil if reviewable.blank?

    login = Login.find_user(data["user_email"], data["user_fbconnect_id"])

    # a fallback - we only have the device ID but the user is not in the database yet, we're storing stuff as anonymous review
    if login.blank?
      AnonymousReview.create_or_update_from_ios_client_data(data)
      return
    end

    new_timestamp = Time.parse(data["timestamp"])

    review_conditions = {
        :reviewer      => login,
        :reviewable    => reviewable,
        :fb_connect_id => login.fb_connect_id
      }

    new_review_data = {
        :content    => data["content"],
        :rating     => data["rating"],
        :created_at => new_timestamp
      }

    review = self.where(review_conditions).first()

    if review
      review.update_attributes(new_review_data) unless new_timestamp < review.created_at
    else
      self.create(review_conditions.merge new_review_data)
    end

  end

  def sanitize_rating
    self.rating = 1 if self.rating.to_i < 1
    self.rating = 5 if self.rating.to_i > 5
  end

  # NOTE: unused right now
  def deliver_review_created_notification_to_flowdock
    ReviewMailer.deliver_notification_on_flowdock self
  end

end