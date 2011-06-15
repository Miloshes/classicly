class SearchController < ApplicationController
  before_filter :initialize_indextank
  
  def show
    @search = params[:term]
    @books =  Search.search_books @search, @indextank, params[:type], params[:page]
  end
  
  def autocomplete
    data = @indextank.search "#{params[:query]} type:book"
    match_count = data['matches']
    docids = data['results'].collect {|datum| datum['docid']}
    results = Search.json_for_autocomplete(docids)
    render :json => results.to_json
  end

  private
  def initialize_indextank
    @indextank ||= IndexTankInitializer::IndexTankService.get_index('classicly_staging')
  end
end
