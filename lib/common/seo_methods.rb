module SeoMethods
  def download_format_page_title(format)
    format = (format == 'azw') ? 'Kindle' : format.upcase
    # 70 chars is the limit, but substract  4 characters for ' by '
    prefix = 'Download'
    if [prefix, self.pretty_title, format].map(&:length).reduce(:+) <= 70
      "#{prefix} #{self.pretty_title} #{format}"
    else
      "#{prefix} #{shorten_title(self.pretty_title, 70 - prefix.length - format.length)}#{format}"
    end
  end
end
