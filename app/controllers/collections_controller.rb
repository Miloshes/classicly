class CollectionsController < ApplicationController
  before_filter :find_collection
  def show
  end

  private
  def find_collection
    @collection = Collection.find(params[:id])
  end
end
