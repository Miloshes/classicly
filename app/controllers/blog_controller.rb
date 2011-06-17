class BlogController < ApplicationController
  def index
    @posts = BlogPost.order('created_at DESC')
  end
end
