include AWS::S3

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

  def download_url_for_format(format)
    object_key = "#{self.id}.#{format}"
    # protected URL, expires in 5 mins
    S3Object.url_for(object_key, APP_CONFIG['buckets']['books'], :expires_in => 300)
  end

  def limited_description(limit)
    return "" if self.description.nil?
    limit = self.description.length - 1 if limit >= self.description.length
    self.description[0..limit] 
  end

  def all_downloadable_formats
    self.download_formats.where({:download_status => 'downloaded'}).map(&:format)
  end

  def classicly_formats
    ['pdf', 'rtf', 'awz'] & self.all_downloadable_formats
  end
  
end
