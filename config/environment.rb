# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Classicly::Application.initialize!

if RAILS_ENV == 'development'
  AUTHORIZE_URL = "http://localhost:3000/auth/facebook"
  USERS_SIGNOUT_URL = 'http://localhost:3000/users/sign_out'
elsif RAILS_ENV == 'production'
  AUTHORIZE_URL = "http://classicly-staging.heroku.com/auth/facebook"
  USERS_SIGNOUT_URL = 'http://classicly-staging.heroku.com/users/sign_out'
end
