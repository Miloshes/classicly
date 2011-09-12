require 'jammit'

namespace :assets do
  
  task :compile => :environment do
    Jammit.package!
  end
  
end
