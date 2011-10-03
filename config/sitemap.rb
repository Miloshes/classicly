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

  Audiobook.find_each do|book|
    sitemap.add author_book_path(book.author, book) unless book.author.nil?
  end

  Book.find_each do|book|
    sitemap.add author_book_path(book.author, book) unless book.author.nil?
  end

  Collection.find_each do|collection|
    sitemap.add seo_path(collection)
  end

  SeoSlug.find_each do|landing_page|
    sitemap.add seo_path(landing_page.slug) unless (landing_page.format == 'all' || landing_page.slug.nil?)
  end
  
  Collection.find_book_author_collections.each do|collection|
    for quote in collection.quotes
      sitemap.add quote_path(collection, quote)
    end
  end

  # add each page from each online readable book to the sitemap
  # Book.where(:is_rendered_for_online_reading).each do |book|
  # 
  #     id = book.seo_slugs.read_online.first.slug
  # 
  #     1.upto(book.book_pages.count) do |page_number|
  #       sitemap.add read_online_path(id, page_number)
  #     end
  #   end

end
