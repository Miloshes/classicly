require 'iconv'

# CLEANUP: add whitespaces, rake task name and namespace name doesn't even match, add documentation what's the script is good for, when to run it

namespace :posts do
  desc 'Reads blog posts from yaml file and imports them to the local database'
  task :update => :environment do
    filepath = APP_CONFIG['yaml_exports_path'] + "/posts.yml"
    data = YAML.load_file(filepath)
    data.each do |record|
      post = BlogPost.find_by_id(record[:id])
      if post
        post.update_attributes :title => record[:title], :content => record[:content], :keywords => record[:keywords]
      else
        BlogPost.create record
      end
    end
    puts "All posts have been imported to the Database"
  end
end
