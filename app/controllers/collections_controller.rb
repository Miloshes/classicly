class CollectionsController < ApplicationController

  def autocomplete
    @collections = Collection.where(:name.matches => "%#{params[:term]}%").select('name').map(&:name)
    render :json => @collections.to_json
  end

  def show_audiobooks
    @collection = Collection.find(params[:id])
    @audiobooks = @collection.get_paginated_books params
  end

  def show_books
    @collection = Collection.find(params[:id])
    @books      = @collection.get_paginated_books params
  end

  def show_quotes
    @collection = Collection.find(params[:id])
    @quotes     = @collection.quotes.page(params[:page]).per(10)
  end

end
