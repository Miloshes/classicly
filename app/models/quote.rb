class Quote < ActiveRecord::Base
  # associations
  belongs_to  :collection
  has_many  :seo_slugs, :as => :seoable
  #extensions
  extend FriendlyId
  friendly_id :quote_slug, use: :slugged, slug_column: "cached_slug"
  #has_friendly_id :quote_slug, :use_slug => true
  
  def quote_slug
    keywords = self.content
    converter = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    # determine how long will be the string of the root path + the quote keywords
    extra = 'http://classicly.com/' + self.collection.try(:name) + '/' # for example http://root/abraham-lincoln/my-quote-abby-lincoln.
    if [extra, keywords].map(&:length).reduce(:+) > 115 # sums every part of the url lengths
      limit = 115 - extra.length  # limit the str length.
      keywords = keywords[0, limit]
    end
    converter.iconv keywords
  end

end
