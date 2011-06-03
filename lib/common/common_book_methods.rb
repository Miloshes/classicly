module CommonBookMethods
  def self.included(base)
    base.class_eval do
      base.extend CommonClassMethods
      scope :no_squat_image, where(:id.not_in => ClassiclyImages::SQUAT_IDS[base.to_s.downcase.pluralize.to_sym])
    end
  end
  
  def description_for_open_graph
    "Download %s for free on Classicly - available as Kindle, PDF, Sony Reader, iBooks and more, or simply read online to your heart's content." % self.pretty_title
  end

  def limited_description(limit)
    return "" if self.description.nil?
    limit = self.description.length - 1 if limit >= self.description.length
    self.description[0..limit]
  end
  
  def view_book_page_title
    if [self.pretty_title ,' by ' , self.author.name].map(&:length).reduce(:+) <= 70
      "#{self.pretty_title} by #{self.author.name}"
    elsif self.pretty_title.length <= 70
      self.pretty_title
    else
      shorten_title 70
    end
  end

  def shorten_title(limit)
    return self.pretty_title if self.pretty_title.length <= limit
    self.pretty_title.slice(0, (limit - 3)).concat("...")
  end

  module CommonClassMethods
    def hashes_for_JSON(books)
      results = []
      books.each do|book|
        results << book.attributes.merge( {:author_slug => book.author.cached_slug } )
      end
      results
    end
  end
end