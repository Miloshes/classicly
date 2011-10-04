class BookHighlightsController < ApplicationController
  
  def show
    @show_right_nav = false
    @book = Book.find(params[:book_id])
    # More probably, it's an anonymous highlight. If it isn't, we take a BookHighlight
    @highlight = AnonymousBookHighlight.find_by_cached_slug(params[:highlight_id]) || BookHighlight.find_by_cached_slug(params[:highlight_id])
  end

end
