# This file is used by Rack-based servers to start the application.

require 'split/dashboard'
require ::File.expand_path('../config/environment',  __FILE__)

Split::Dashboard.use Rack::Auth::Basic do |username, password|
    username == 'admin' && password == 'ectoralt77'
  end

run Rack::URLMap.new("/" => Classicly::Application, "/split-testing-dashboard" => Split::Dashboard.new)
