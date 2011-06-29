class Admin::SeoDefaultsController < Admin::BaseController
  before_filter :find_seo_default, :only => [:edit, :show, :update]
  def index
    @seo_defaults = SeoDefault.all
  end

  def new
    @seo_default = SeoDefault.new
  end
  
  def create
    @seo_default = SeoDefault.new(params[:seo_default])
    if @seo_default.save
      redirect_to admin_seo_defaults_path
    else
      render :action => :new
    end
  end
  
  def edit
  end
  
  def update
    if @seo_default.update_attributes(params[:seo_default])
      redirect_to admin_seo_defaults_path
    else
      render :action => :edit
    end
  end
  
  def show
    if @seo_default.object_type == 'Book'
      @book = Book.first
    elsif @seo_default.object_type == 'Audiobook'
      @audiobook = Audiobook.first
    end
  end
  
  private
  
  def find_seo_default
    @seo_default = SeoDefault.find params[:id]
  end
end