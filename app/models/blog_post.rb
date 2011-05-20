class BlogPost < ActiveRecord::Base
  has_friendly_id :blog_post_slug, :use_slug => true, :strip_non_ascii => true
  
  def blog_post_slug
    self.title.downcase.rstrip.gsub(' ', '-')
  end
end
