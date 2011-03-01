class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :find_covers
  
  protected
  def find_covers
    @covers = Book.where({:blessed => true}).limit(8)
  end
end
