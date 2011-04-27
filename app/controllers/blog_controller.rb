class BlogController < ApplicationController
  layout 'blog'
  def index
    @posts = BlogPost.all
  end
end
