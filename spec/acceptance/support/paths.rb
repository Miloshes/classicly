module NavigationHelpers
  # Put helper methods related to the paths in your application here.

  def homepage
    "/"
  end
  
  def collections
    collections_path
  end
end

RSpec.configuration.include NavigationHelpers, :type => :acceptance