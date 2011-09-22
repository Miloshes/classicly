class BookHighlightsController < ApplicationController

  def show
    @book = Book.find(params[:book_id])
    
    # More probably, it's an anonymous highlight
    @highlight = AnonymousBookHighlight.where(:cached_slug => params[:quote_slug]).first()
    
    # Turns out it's a normal highlight, done by a registered user
    if @highlight.blank?
      @highlight = BookHighlight.where(:cached_slug => params[:quote_slug]).first()
    end
    
    render :text => @highlight.inspect
  end

end
