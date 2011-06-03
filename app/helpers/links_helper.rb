module LinksHelper
  def read_online_link(book)
    link_to image_tag('read-online-focus.png'), "/#{book.seo_slugs.read_online.first.slug}/page/1"
  end
end