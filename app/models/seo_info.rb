class SeoInfo < ActiveRecord::Base
  belongs_to :infoable, :polymorphic => true
  
  def infoable_title
    return 'Not applicable' if self.infoable.is_a?(SeoSlug)
    if ['Book', 'Audiobook', 'Collection'].include?(self.infoable_type)
      self.infoable.respond_to?(:pretty_title) ? self.infoable.pretty_title : self.infoable.name
    end
  end
  
  def infoable_title=(title)
    return if title.blank?
    if ['Book', 'Audiobook', 'Collection'].include?(self.infoable_type)
      self.infoable.respond_to?(:pretty_title) ? (self.infoable.pretty_title = title) : (self.infoable.name = title)
    end
    self.infoable.save
    self.infoable.update_seo_slugs if ['Book', 'Audiobook'].include?(self.infoable_type)
  end
end