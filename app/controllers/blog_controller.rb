class BlogController < ApplicationController
  layout 'blog'

  before_filter :find_author_collections
  before_filter :find_genre_collections

  def index
    @posts = BlogPost.all
  end
end
