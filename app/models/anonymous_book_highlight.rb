class AnonymousBookHighlight < ActiveRecord::Base
  belongs_to :book
  
  validates :first_character, :presence => true
  validates :last_character, :presence => true
  validates :book, :presence => true
  
  # we tie anonymous highlights to device IDs, so we can attach them to the user when he registers
  validates :ios_device_id, :presence => true
  
  def self.create_or_update_from_ios_client_data(data)
    book = Book.find(data["book_id"].to_i)

    return nil if book.blank?
    
    new_timestamp = Time.parse(data["timestamp"])
  
    highlight_conditions = {
        :ios_device_id   => data["device_id"],
        :book            => book,
        :content         => data["content"],
        :first_character => data["first_character"],
        :last_character  => data["last_character"]
      }

    new_highlight_data = {
        :created_at      => new_timestamp
      }
  
    highlight = self.where(highlight_conditions).first()
  
    if highlight
      highlight.update_attributes(new_highlight_data) unless new_timestamp < highlight.created_at
    else
      self.create(highlight_conditions.merge new_highlight_data)
    end
  end
  
end
