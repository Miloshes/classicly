class SearchController < ApplicationController
  def show
    @search = params[:term]
    @books =  Search.search_books @search, @indextank, params[:type], params[:page]
    if params[:type]
      @audibly = true
      render :layout => 'audibly'
    end
  end
  
  def autocomplete
    data = @indextank.search "#{params[:query]} type:book"
    match_count = data['matches']
    docids = data['results'].collect {|datum| datum['docid']}
    results = Search.json_for_autocomplete(docids)
    render :json => results.to_json
  end
end
