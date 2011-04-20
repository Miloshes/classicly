class Author < ActiveRecord::Base
  has_many :books
  has_many :audiobooks
  has_many :reviews, :as => :reviewable
  has_friendly_id :name, :use_slug => true
  
 
  def audio_collection
    Collection.where(:name.matches => "%#{self.name}%", :book_type => 'audiobook').first
  end
  
  def has_audio_collection?
    Collection.exists?(['name LIKE ? AND book_type = ? ', "%#{self.name}%", 'audiobook'])
  end
end
