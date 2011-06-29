xml.instruct! :xml, :version => '1.0'
xml.rss :version => '2.0' do
  xml.channel do
    xml.title 'Classicly Blog'
    xml.description "This is Book Blog, a weblog by Spreadsong about literature, classic authors, ereading, and our mobile apps, Free Books and Free Audiobooks, for iPhone and iPad."
    xml.link blog_url(:format => :rss)
    for post in @posts
      xml.item do
        xml.title post.title
        xml.description markdown(post.content)
        xml.pubDate post.created_at.to_s(:rfc822)
      end
    end
  end
end