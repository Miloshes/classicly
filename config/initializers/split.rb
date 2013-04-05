Split.configure do |config|
  config.db_failover = true # handle redis errors gracefully
  config.db_failover_on_db_error = proc{|error| Rails.logger.error(error.message) }
  config.allow_multiple_experiments = true # It's fine for me, but might not for you
  config.enabled = true
end

Split::Dashboard.use Rack::Auth::Basic do |username, password|
  username == 'admin' && password == 'ectoralt77'
end

Split.redis.namespace = "split:mobile-upsell" # Any name you want

# Make Split use Redis To Go on Heroku
Split.redis = ENV["REDISTOGO_URL"] if ENV["REDISTOGO_URL"]