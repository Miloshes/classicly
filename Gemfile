source "https://rubygems.org"
source "http://gems.github.com"

ruby '2.2.0'
gem "rails", "4.2.1"
gem "protected_attributes"
gem "pg"
gem "iconv"
gem "activerecord-session_store"
gem "jquery-ui-rails"

group :assets do 
  gem 'coffee-rails'
  gem 'sass-rails'
  gem 'uglifier'
  gem "compass-rails", github: "Compass/compass-rails", branch: "master"
  gem 'compass-blueprint'
end

# Authentication - http://rubygems.org/gems/authlogic
gem "authlogic", :git => "git://github.com/binarylogic/authlogic.git"

# Amazon S3 - http://amazon.rubyforge.org/
gem "aws-s3", :require => "aws/s3", :git => 'https://github.com/bartoszkopinski/aws-s3'
# gem "aws-sdk", :require => "aws/s3"

# CSS Authoring Framework - http://rubygems.org/gems/compass
#gem "compass", "1.0.3"

# template markup language - http://haml-lang.com/
gem "haml"

# SEO slugs and permalinks - http://rubygems.org/gems/friendly_id
gem "friendly_id", '~> 5.0.0'

# app error app - http://hoptoadapp.com/pages/home
gem "airbrake"

# hosted search - http://indextank.com/
gem "indextank"

# asset packaging - http://documentcloud.github.com/jammit/
#gem "jammit"

# JQuery for Rails - https://github.com/indirect/jquery-rails
gem "jquery-rails"

# paginator gem - https://rubygems.org/gems/kaminari
gem "kaminari"

# Facebook SDK - https://rubygems.org/gems/koala
gem "koala"

# Kissmetrics Api - http://rubygems.org/gems/kissmetrics
gem "km"

# gem to parse Mardown markup to HTML
gem "maruku"

# extends ActiveRecord where conditions - http://metautonomo.us/projects/metawhere/
#gem "meta_where"

# html/xml parser - http://rubygems.org/gems/nokogiri
gem "nokogiri"

# file upload management with S3 support - http://rubygems.org/gems/paperclip
gem "paperclip", "~> 2.4.5"

# HTTP REST client - http://rubygems.org/gems/rest-client
gem "rest-client", :require => "rest_client"

# Sitemap generator - http://rubygems.org/gems/sitemap_generator
gem "sitemap_generator"

# SQLite3 driver - http://rubygems.org/gems/sqlite3
#gem "sqlite3"

# gem to allow sort and pagination using regular HTML and avoid showing the params in the URL
gem "sorted"

# gem to support state machine behavior in ruby classes - http://rubygems.org/gems/state_machine
gem "state_machine"

# encode/decode HTML entities (like &yacute;) - http://rubygems.org/gems/htmlentities
gem "htmlentities"

# Asynchronously execute longer tasks in the background - http://rubygems.org/gems/delayed_job
gem "delayed_job"

# read and write zip files - http://rubygems.org/gems/rubyzip
gem "rubyzip"

# Heroku supported memcached client - http://rubygems.org/gems/dalli
gem "dalli"

# For handling the API version numbers nicely - https://github.com/dazuma/versionomy
gem "versionomy", "0.4.1"

gem 'hominid'

# A/B testing framework
gem 'split', :require => 'split'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :development, :test do
  # nicer output for console debugging - http://rubygems.org/gems/awesome_print
  # gem "awesome_print"
  
  # Ruby debugger console - http://rubygems.org/gems/ruby-debug
  #gem "ruby-debug19"
  
  # Heroku database import/export - http://rubygems.org/gems/taps
  # NOTE: only enable when used, has a gem version conflict with the "split" gem
  # gem "taps"
  
  # Can control the Firefox browser, used for book rendering - http://rubygems.org/gems/firewatir
  # gem "firewatir"
  
  # == Testing related
  # improve tests performance
  gem "spork", "0.9.2"
  
  # Testing framework, a Cucumber replacement - http://rubygems.org/gems/steak
  gem "steak"

  # integration testing - http://rubygems.org/gems/capybara
  gem "capybara"
  
  # a different driver than selenium for acceptance tests
  #gem "akephalos", "~> 0.2.5"

  # for cleaning the DB for tests - http://rubygems.org/gems/database_cleaner
  gem "database_cleaner"

  # fixtures generator for tests - https://github.com/thoughtbot/factory_girl
  # docs: http://rubydoc.info/gems/factory_girl/2.2.0/frames
  gem "factory_girl"
  
  # Rails integration for Factory girl, doesn't do much just autoloads factory definitions - https://github.com/thoughtbot/factory_girl_rails
  gem "factory_girl_rails"
  
  # Gem that has the autotest tool for automatically running the tests. http://rubygems.org/gems/ZenTest
  # gem "ZenTest"
  
  # Gem for reporting passing and failing tests via Growl on OS X. https://rubygems.org/gems/autotest-growl
  # gem "autotest-growl", "~> 0.2.9"
  
  # Autotest will not poll the filesystem for changes, but uses OS X APIs instead (much faster) http://rubygems.org/gems/autotest-fsevent
  # NOTE: requires XCode to work. Disabling this until Ruby 1.9.3 and Xcode 4.3 plays along
  # gem "autotest-fsevent"
  
  # RSpec BDD testing framework - http://rubygems.org/gems/rspec
  gem "rspec-rails"
  
  # makes Capybara able to show the browser in the last state - http://rubygems.org/gems/launchy
  gem "launchy"
end
