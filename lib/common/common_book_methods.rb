module CommonBookMethods
  def self.included(base)
    base.class_eval do
      base.extend CommonClassMethods
      scope :no_squat_image, where(:id.not_in => ClassiclyImages::SQUAT_IDS[base.to_s.downcase.pluralize.to_sym])
    end
  end

  def average_rating
    self.reviews.blank? ? 0 : (self.reviews.sum('rating').to_f / self.ratings.size.to_f).round
  end

  def has_slug_for_format?(format)
    return false if self.seo_slugs.empty?
    self.seo_slugs.send(format).first.nil? ? false : true
  end

  def limited_description(limit)
    return "" if self.description.nil?
    limit = self.description.length - 1 if limit >= self.description.length
    self.description[0..limit]
  end

  def rating_by_user(user)
    rating = self.ratings.find_by_fb_connect_id(user.fb_connect_id)
    rating.try(:score)
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
