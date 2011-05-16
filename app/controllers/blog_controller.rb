class BlogController < ApplicationController
  layout 'new_design'

  before_filter :find_author_collections
  before_filter :find_genre_collections

  def index
    @posts = BlogPost.all
  end
end
