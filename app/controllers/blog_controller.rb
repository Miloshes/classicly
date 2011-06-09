class BlogController < ApplicationController
  def index
    @posts = BlogPost.all
  end
end
