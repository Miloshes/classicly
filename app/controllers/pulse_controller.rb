class PulseController < ApplicationController
  def index
    @pulse_elements = Review.order('created_at DESC').limit(10) + BookHighlight.order('created_at DESC').limit(5)
  end
end