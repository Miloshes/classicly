class BookHighlightsController < ApplicationController
  
  def show
    @show_right_nav = false
    @book = Book.find(params[:book_id])
    # More probably, it's an anonymous highlight. If it isn't, we take a BookHighlight
    @highlight = AnonymousBookHighlight.find_by_cached_slug(params[:highlight_id]) || BookHighlight.find_by_cached_slug(params[:highlight_id])
    
    message_handler = ShareMessageHandler.new

    @message_for_twitter = message_handler.get_message_for(
        :target_platform => "twitter",
        :message_type    => "highlight share",
        :highlight       => @highlight,
        :book            => @book
      )
    @message_for_facebook = message_handler.get_message_for(
        :target_platform => "facebook",
        :message_type    => "highlight share",
        :highlight       => @highlight,
        :book            => @book
      )
    
  end

end
