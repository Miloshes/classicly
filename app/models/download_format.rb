class DownloadFormat < ActiveRecord::Base
  belongs_to :book
  
  validates :book, :presence => true
  validates :format, :presence => true
end
