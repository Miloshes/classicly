class UserUploadedContent < ActiveRecord::Base
  
  has_many :book_delivery_packages, :as => :deliverable
  
end
