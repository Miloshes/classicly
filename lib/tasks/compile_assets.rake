require 'jammit'

namespace :assets do
  
  task :compile => :environment do
    Jammit.package! :base_url => "http://www.classicly.com/"
  end
  
end
