class BlogController < ApplicationController
  layout 'new_design'

  def index
    @posts = BlogPost.all
  end
  
  def show
    @post = BlogPost.find params[:id]
  end
end
