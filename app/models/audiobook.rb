class Audiobook < ActiveRecord::Base
  belongs_to :author
  belongs_to :custom_cover

  has_many :audio_collection_audio_book_assignments, :foreign_key => 'audio_book_id'
  has_many :audio_collections, :through => :audio_collection_audiobook_assignments

  validates :title, :presence => true

  scope :blessed, where({:blessed => true})
  scope :random, lambda { |limit| {:order => 'RANDOM()', :limit => limit }}

  has_friendly_id :pretty_title, :use_slug => true

  def find_fake_related(num = 8)
    result = []

    # Two sources for related books:
    #  - popular books from the same genres with the same language [not implemented yet]
    #  - other books of the author with the same language


    # == Other books of the author, with the same language
    audio_books_from_same_author = self.author.audiobooks.where("id <> ?", self.id)

    result = choose_audio_books(num, result, audio_books_from_same_author)

    result.compact!
    result.sort_by { rand }
    result
  end

  # NOTE: in case the result set is empty, it should fall back to books from the same author, or just blessed books
  def find_more_from_same_collection(num = 2)
    result = []

    # == books from the same collection
    audio_books_to_choose_from = []

    self.collections.each do |collection|
      audio_books_to_choose_from += collection.audiobooks.where("audiobooks.id <> ?", self.id)
    end

    result = choose_audio_books(num, result, audio_books_to_choose_from)
    # == books from the same author as a fallback
    result = choose_audio_books(num, result, self.author.audiobooks.where("id <> ?", self.id))
    # == blessed books
    result = choose_audio_books(num, result, Audiobook.where("id <> ? AND blessed = ?", self.id, true))

    return result
  end

  private
  def choose_audio_books(limit, result, collection_to_choose_from)
    1.upto(limit - result.size) do
      break if collection_to_choose_from.blank?
      position = rand(collection_to_choose_from.size)
      result << collection_to_choose_from[position]
      collection_to_choose_from.delete_at(position)
    end
    result
  end
end
