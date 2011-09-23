source :rubygems
source 'http://gems.github.com'

gem 'rails', '3.0.7'

# Authentication - http://rubygems.org/gems/authlogic
gem "authlogic", :git => "git://github.com/binarylogic/authlogic.git"

# Amazon S3 - http://amazon.rubyforge.org/
gem 'aws-s3', :require => 'aws/s3'

# CSS Authoring Framework - http://rubygems.org/gems/compass
gem "compass", ">= 0.10.5"

# needed by mongrel to run on ruby 1.9.2
gem "cgi_multipart_eof_fix"
gem "fastthread"

# template markup language - http://haml-lang.com/
gem 'haml'

# SEO slugs and permalinks - http://rubygems.org/gems/friendly_id
gem "friendly_id", "~> 3.2.1"

# app error app - http://hoptoadapp.com/pages/home
gem 'hoptoad_notifier'

# hosted search - http://indextank.com/
gem 'indextank'

# asset packaging - http://documentcloud.github.com/jammit/
gem 'jammit'

# JQuery for Rails - https://github.com/indirect/jquery-rails
gem 'jquery-rails'

# paginator gem - https://rubygems.org/gems/kaminari
gem 'kaminari'

# Facebook SDK - https://rubygems.org/gems/koala
gem 'koala'

# gem to parse Mardown markup to HTML
gem 'maruku'

# extends ActiveRecord where conditions - http://metautonomo.us/projects/metawhere/
gem 'meta_where'

# web server for local development
gem "mongrel", "1.2.0.pre2"

# html/xml parser - http://rubygems.org/gems/nokogiri
gem "nokogiri"

# file upload management with S3 support - http://rubygems.org/gems/paperclip
gem "paperclip"

# HTTP REST client - http://rubygems.org/gems/rest-client
gem 'rest-client', :require => 'rest_client'

# Sitemap generator - http://rubygems.org/gems/sitemap_generator
gem 'sitemap_generator'

# SQLite3 driver - http://rubygems.org/gems/sqlite3
gem 'sqlite3-ruby'

# gem to allow sort and pagination using regular HTML and avoid showing the params in the URL
gem 'sorted'

#gem to support state machine behavior in ruby classes
gem 'state_machine'

# encode/decode HTML entities (like &yacute;) - http://rubygems.org/gems/htmlentities
gem 'htmlentities'

# Asynchronously execute longer tasks in the background - http://rubygems.org/gems/delayed_job
gem 'delayed_job'

# read and write zip files - http://rubygems.org/gems/rubyzip
gem 'rubyzip'

# Heroku supported memcached client - http://rubygems.org/gems/dalli
gem 'dalli'

group :development, :test do
  # nicer output for console debugging - http://rubygems.org/gems/awesome_print
  gem 'awesome_print'
  
  # Ruby debugger console - http://rubygems.org/gems/ruby-debug
  # NOTE: for Ruby v1.9 use ruby-debug19!
  gem 'ruby-debug19'
  
  # Heroku database import/export - http://rubygems.org/gems/taps
  gem 'taps', '> 0.3.22'
  
  # Can control the Firefox browser, used for book rendering - http://rubygems.org/gems/firewatir
  gem 'firewatir'
  
  # == Testing related
  # improve tests performance
  gem 'spork', '0.9.0.rc8'
  
  # Testing framework, a Cucumber replacement - http://rubygems.org/gems/steak
  gem 'steak'

  # integration testing - http://rubygems.org/gems/capybara
  gem 'capybara'
  
  # a different driver than selenium for acceptance tests
  gem "akephalos", "~> 0.2.5"

  # for cleaning the DB for tests - http://rubygems.org/gems/database_cleaner
  gem "database_cleaner"

  # fixtures generator for tests
  gem 'factory_girl'

  # Javascript testing framework - http://rubygems.org/gems/jasmine
  #gem 'jasmine'

  # fixtures generator for testing - http://rubygems.org/gems/machinist
  #gem 'machinist', '>= 2.0.0.beta1'
  
  # Gem that has the autotest tool for automatically running the tests. http://rubygems.org/gems/ZenTest
  gem 'ZenTest'
  
  # Gem for reporting passing and failing tests via Growl on OS X. https://rubygems.org/gems/autotest-growl
  gem 'autotest-growl', '~> 0.2.9'
  
  # Autotest will not poll the filesystem for changes, but uses OS X APIs instead (much faster) http://rubygems.org/gems/autotest-fsevent
  gem 'autotest-fsevent'
  
  # RSpec BDD testing framework - http://rubygems.org/gems/rspec
  gem 'rspec-rails'
  
  # makes Capybara able to show the browser in the last state - http://rubygems.org/gems/launchy
  gem 'launchy'
end
