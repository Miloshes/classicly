class Quote < ActiveRecord::Base
  # associations
  belongs_to  :collection
  has_many  :seo_slugs, :as => :seoable
  #extensions
  has_friendly_id :quote_slug, :use_slug => true
  
  def quote_slug
    keywords = self.content_without_stop_words
    converter = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    # determine how long will be the string of the root path + the quote keywords
    extra = 'http://classicly.com/' + self.collection.try(:name) + '/' # for example http://root/abraham-lincoln/my-quote-abby-lincoln.
    if [extra, keywords].map(&:length).reduce(:+) > 115 # sums every part of the url lengths
      limit = 115 - extra.length  # limit the str length.
      keywords = keywords[0, limit]
    end
    converter.iconv keywords
  end
  
  def content_without_stop_words
    stop_words = %w{ a about an are as at be by in is it of on or that the this to was what when where who will with the}
    words = self.content.scan(/\w+/)
    key_words = words.select { |word| !stop_words.include?(word) }
    key_words.join('-')
  end
end
