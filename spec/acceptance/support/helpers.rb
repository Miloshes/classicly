module HelperMethods
  # Put helper methods you need to be available in all acceptance specs here.
  def collection_slug(url_str)
    url_str.split('/').last
  end
end

RSpec.configuration.include HelperMethods, :type => :acceptance