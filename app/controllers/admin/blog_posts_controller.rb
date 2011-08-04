class Admin::BlogPostsController < Admin::BaseController
  before_filter :set_blog_post, :only => [:destroy, :edit, :update, :show]
  
  def index
    @blog_posts = BlogPost.order('created_at DESC')
  end

  def new
    @blog_post = BlogPost.new
    @blog_post.custom_resources.build
  end

  def create
    @blog_post = BlogPost.new(params[:blog_post])
    if @blog_post.save
      redirect_to edit_admin_blog_post_path(@blog_post)
    else
      render :action => :new
    end
  end

  def edit
    @blog_post.custom_resources.build
  end

  def update
    if BlogPost.persist(@blog_post, params[:blog_post])
      redirect_to edit_admin_blog_post_path(@blog_post)
    else
      render :action => :edit
    end
  end

  def destroy
    @post.delete
    redirect_to blog_posts_path
  end

  def associate_book
    book = Book.find(params[:id])
    blog_post = BlogPost.find(params[:blog_post_id])
    params[:delete] ? blog_post.related_books.delete(book) : blog_post.related_books << book
    blog_post.save
    render :text => '' 
  end
  
  def change_state
    @blog_post = BlogPost.find(params[:id])
    @blog_post.send(params[:event].to_sym)
    @links = ''
    @blog_post.state_transitions.each do|transition|
      @links += "<a data-remote='true' href='/admin/blog_posts/#{@blog_post.id}/change_state?event=#{transition.event}'>#{transition.event.to_s}</a>"
    end
  end

  def preview
    @post = BlogPost.find(params[:id])
  end
  
  private
  
  def set_blog_post
    @blog_post = BlogPost.find(params[:id])
  end
end
