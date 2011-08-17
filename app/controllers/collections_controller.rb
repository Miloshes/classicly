class CollectionsController < ApplicationController

  def autocomplete
    @collections = Collection.of_type('book').collection_type('author').where(:name.matches => "%#{params[:term]}%").select('name').map(&:name)
    render :json => @collections.to_json
  end

end
