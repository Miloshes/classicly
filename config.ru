# This file is used by Rack-based servers to start the application.

require 'split/dashboard'
require ::File.expand_path('../config/environment',  __FILE__)

run Rack::URLMap.new("/" => Classicly::Application, "/split-testing-dashboard" => Split::Dashboard.new)
