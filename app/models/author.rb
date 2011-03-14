class Author < ActiveRecord::Base
  has_many :books
  has_many :audiobooks
  has_many :reviews, :as => :reviewable
  has_friendly_id :name, :use_slug => true
end
