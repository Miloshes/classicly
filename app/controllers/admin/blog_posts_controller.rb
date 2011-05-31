class Admin::BlogPostsController < Admin::BaseController
  before_filter :set_blog_post, :only => [:destroy, :edit, :update, :show]
  def index
    @blog_posts = BlogPost.all
  end

  def new
    @blog_post = BlogPost.new
  end

  def create
    @blog_post = BlogPost.new(params[:blog_post])
    if @blog_post.save
      redirect_to admin_blog_posts_path
    else
      render :action => :new
    end
  end

  def edit
  end

  def update
    if BlogPost.persist(@blog_post, params[:blog_post])
      redirect_to admin_blog_posts_path
    else
      render :action => :edit
    end
  end

  def destroy
    @post.delete
    redirect_to blog_posts_path
  end

  private
  
  def set_blog_post
    @blog_post = BlogPost.find(params[:id])
  end
end
