# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Classicly::Application.initialize!

FACEBOOK_APP_ID = '142787879122425'

if Rails.env == 'development'
  AUTHORIZE_URL = "http://localhost:3000/auth/facebook"
  USERS_SIGNOUT_URL = 'http://localhost:3000/users/sign_out'
elsif Rails.env == 'production'
  AUTHORIZE_URL = "http://classicly-staging.heroku.com/auth/facebook"
  USERS_SIGNOUT_URL = 'http://classicly-staging.heroku.com/users/sign_out'
end
