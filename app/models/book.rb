class Book < ActiveRecord::Base
  belongs_to :author
  belongs_to :custom_cover
  
  has_many :collection_book_assignments
  has_many :collecions, :through => :collection_book_assignments
  has_and_belongs_to_many :genres
  
  has_many :download_formats
  
  validates :title, :presence => true
  
  def available_in_format?(format)
    ! self.download_formats.where({:format => format, :download_status => 'downloaded'}).blank?
  end
end
