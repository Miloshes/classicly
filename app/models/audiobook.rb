class Audiobook < ActiveRecord::Base
  include Sluggable, SeoMethods, CommonBookMethods

  belongs_to :author
  belongs_to :custom_cover
  
  has_many :chapters, :class_name => 'AudiobookChapter'

  has_many :collection_audiobook_assignments
  has_many :collections, :through => :collection_audiobook_assignments
  has_many :reviews, :as => :reviewable
  has_many :seo_slugs, :as => :seoable

  validates :title, :presence => true

  scope :blessed, where({:blessed => true})
  scope :order_by_author, joins(:author) & Author.order('name')
  scope :random, lambda { |limit| {:order => (Rails.env.production? || Rails.env.staging?) ? 'RANDOM()': 'RAND()', :limit => limit }}

  has_friendly_id :audio_book_slugs, :use_slug => true

  def self.search(term, current_page)
    self.joins('LEFT OUTER JOIN collection_audiobook_assignments ON audiobooks.id = collection_audiobook_assignments.audiobook_id').
        joins('LEFT OUTER JOIN collections ON collections.id = collection_audiobook_assignments.collection_id').
        joins(:author).where({:title.matches => "%#{term}%"} |
    {:collections => {:name.matches => "%#{term}%"}} |
    {:author => {:name.matches => "%#{term}%"}}).select('DISTINCT audiobooks.*').page(current_page).per(10)
  end

  def choose_audio_books(limit, already_chosen_books, collection_to_choose_from)
    1.upto(limit - already_chosen_books.size) do
      break if collection_to_choose_from.blank?
      position = rand(collection_to_choose_from.size)
      already_chosen_books << collection_to_choose_from.delete_at(position)
    end
    already_chosen_books
  end

  def find_fake_related(number = 8)
    chosen_books = []

    # Two sources for related books:
    #  - other books associated to similar collections
    #  - other books of the author with the same language

    # == Other books of the author, with the same language
    audio_books_from_same_author = self.author.audiobooks.where("id <> ?", self.id)
    chosen_books = choose_audio_books(number, chosen_books, audio_books_from_same_author)

    audio_books_from_same_collections = []
    self.collections.each { |collection| audio_books_from_same_collections+= collection.audiobooks }
    chosen_books = choose_audio_books(number, chosen_books, audio_books_from_same_collections)

    chosen_books.compact!
    chosen_books.sort_by {rand} 
  end

  # NOTE: in case the result set is empty, it should fall back to books from the same author, or just blessed books
  def find_more_from_same_collection(num = 2)
    result = []

    # == books from the same collection
    audio_books_to_choose_from = []

    self.collections.each do |collection|
      audio_books_to_choose_from += collection.audiobooks.where('audiobooks.id <> ?', self.id)
    end

    result = choose_audio_books(num, result, audio_books_to_choose_from)
    # == books from the same author as a fallback
    result = choose_audio_books(num, result, self.author.audiobooks.where("id <> ?", self.id))
    # == blessed books
    result = choose_audio_books(num, result, Audiobook.where("id <> ? AND blessed = ?", self.id, true))

    return result
  end

  def generate_seo_slugs(formats)
    formats.each do|format|
      slug = optimal_url_for_download_page(format)
      # if you find a similar slug due to shortening of the cached slug such as in
      # "the-first-epistle-of-paul-the-apostle-to-the-corinthians-audiobook"
      # "the-first-epistle-of-paul-the-apostle-to-timothy-audiobook"
      # make sure you create a diferent slug:
      other_slug = SeoSlug.where :slug.matches => "%#{slug}%"
      slug << "[#{other_slug.size + 1 }]" unless other_slug.empty?
      SeoSlug.find_or_create_by_slug(slug, {:seoable_id => self.id, :seoable_type => self.class.to_s, :format => format})
    end
  end

  def html_title
    if [self.pretty_title ,' by ' , self.author.name].map(&:length).reduce(:+) <= 70
      "#{self.pretty_title} by #{self.author.name}"
    elsif self.pretty_title.length <= 70
      self.pretty_title
    else
      shorten_title 70
    end
  end


  def log_book_view_in_mix_panel(user_id, mix_panel_object)
    mix_panel_properties = {:title => self.pretty_title}
    if user_id
      mix_panel_properties.merge!({:id => user_id})
    end
    mix_panel_object.track_event("Viewed Book", mix_panel_properties)
  end
  
  def has_rating?
    self.avg_rating > 0
  end
  
  def set_average_rating
    self.avg_rating = self.reviews.blank? ? 0 : (self.reviews.sum('rating').to_f / self.reviews.size.to_f).round
    self.save
  end
  
  def shorten_title(limit)
    return self.pretty_title if self.pretty_title.length <= limit
    self.pretty_title.slice(0, (limit - 3)).concat("...")
  end

  private

  def audio_book_slugs
    "#{pretty_title}-audiobook"
  end
end
