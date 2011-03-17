# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://www.classicly.com"

SitemapGenerator::Sitemap.add_links do |sitemap|
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: sitemap.add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  # 
  # 
  # Examples:
  # 
  # Add '/articles'
  #   
  #   sitemap.add articles_url, :priority => 0.7, :changefreq => 'daily'
  #
  # Add individual articles:
  #
  #   Article.find_each do |article|
  #     sitemap.add article_url(article), :lastmod => article.updated_at
  #   end
  Book.find_each do|book|
    sitemap.add author_book_url(book.author, book) unless book.author.nil?
  end

  Collection.find_each do|collection|
    sitemap.add seo_url(collection)
  end
end
