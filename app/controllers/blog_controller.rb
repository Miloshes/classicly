class BlogController < ApplicationController
  def index
    @posts = BlogPost.all
  end
  
  def show
    @blog_post = BlogPost.find(params[:id])
  end
end
