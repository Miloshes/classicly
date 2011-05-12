class Author < ActiveRecord::Base
  has_many :books
  has_many :audiobooks
  has_many :reviews, :as => :reviewable
  has_friendly_id :name, :use_slug => true
  
 
  def audio_collection
    Collection.where(:name.matches => "%#{self.name}%", :book_type => 'audiobook').first
  end

  def collection
    Collection.where(:name.matches => "%#{self.name}%", :book_type => 'book').first
  end

  def featured_book(type='book')
    type.classify.constantize.where(:author_id => self.id).first
  end

  def has_audio_collection?
    Collection.exists?(['name LIKE ? AND book_type = ? ', "%#{self.name}%", 'audiobook'])
  end

  def has_collection?
    Collection.exists?(['name LIKE ? AND book_type = ? ', "%#{self.name}%", 'book'])
  end

  def related_books(limit, type = 'book' )
    klass = type.classify.constantize
    books = klass.where(:author_id => self.id, :blessed => true).limit(8)
    unless books.count >= limit
      new_limit = limit -books.count
      books+= klass.where(:author_id => self.id, :blessed => false).limit(new_limit)
    end
  end
end
