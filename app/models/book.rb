include AWS::S3

class Book < ActiveRecord::Base
  include Descriptable
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
    AWS::S3::Base.establish_connection!(
        :access_key_id     => APP_CONFIG['amazon']['access_key'],
        :secret_access_key => APP_CONFIG['amazon']['secret_key']
      )
    
    object_key = "#{self.id}.#{format}"
    # protected URL, expires in 5 mins
    S3Object.url_for(object_key, APP_CONFIG['buckets']['books'], :expires_in => 300)
  end

  def all_downloadable_formats
    self.download_formats.all(:conditions => ['download_status = ?', 'downloaded'], :select => ['format']).map{|format| format.format}
  end

  def classicly_formats
    ['pdf', 'azw', 'rtf'] & self.all_downloadable_formats
  end
  
  def self.random_blessed_books(num = 8)
    blessed_books = self.where(:blessed => true)
    return [] if blessed_books.blank?
    
    result = []
    
    1.upto num do
      position = rand(blessed_books.size)
      result << blessed_books[position]
      blessed_books.delete_at(position)
      num = num-1 if num > 0
    end
      
    return result
  end
  
end
