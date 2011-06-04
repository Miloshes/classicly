class AbingoDashboardController < ApplicationController
  #TODO add some authorization
  layout 'abingo'
  include Abingo::Controller::Dashboard
  before_filter :require_user
end
