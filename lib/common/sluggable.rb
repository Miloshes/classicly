require 'iconv'
module Sluggable

  def author_book_slug
    "#{self.author.cached_slug}/#{self.cached_slug}"
  end

  def optimal_url_for_download_page(format)
    converter = Iconv.new('UTF-8//IGNORE', 'UTF-8')

    #determine how long will be the string of the root path + the format
    extra = 'download-' # for example http://root/download-[x]
    extra << (format.nil? ? URL_CONFIG['root_path'] : URL_CONFIG['root_path'] + "-#{format}") #[root_path]/download-x-[format]
    str = self.cached_slug.clone #cached_slug has the book string such as 'unbearable-lightness-of-being'
    if [extra, self.cached_slug, uniqueness_indicator].map(&:length).reduce(:+) > 75 # sums every part of the url lengths
      limit = 75 - extra.length - uniqueness_indicator.length #limit the str length
      str = str[0, limit]
    end
    #posibilities
    #[root_path]/download-the-boo-pdf
    #[root_path]/download-the-book-pdf
    #[root_path]/download-the-boo--2-pdf
    format = "-#{format}" if uniqueness_indicator.length > 0 ||  str[-1, 1] != '-' #add a hyphen unless the last char is already one,
    converter.iconv("download-" + str + uniqueness_indicator + format)
  end

  def uniqueness_indicator
    if mark = self.cached_slug =~ /--\d/
      return self.cached_slug[mark, self.cached_slug.size]
    end
    return ''
  end

  def url_for_specific_format(format)
    return "/#{self.seo_slugs.where(:format => 'kindle').first.slug}" if format == 'azw'
    "/#{self.seo_slugs.where(:format => format).first.slug}"
  end
end