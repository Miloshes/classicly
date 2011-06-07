class Admin::AdminSeoController < Admin::BaseController
  before_filter :find_seo_infoable, :only => [:edit_seo, :update_seo_info]

  def admin_infoable
    @type = params[:type]
    klass = @type.classify.constantize
    
    @elements = if params[:search]
      (@type == 'seo_slug') ? klass.search(params[:search], params[:page], 25, params[:book_type]) : 
        klass.search(params[:search], params[:page], 25)
    else
      klass.page(params[:page]).per(25)
    end
  end

  def edit_seo
    @seo_info = @element.seo_info || SeoInfo.new
  end

  def main
  end
  
  def update_seo_info
    @seo_info = @element.seo_info || @element.build_seo_info(params[:seo_info])
    ok = @seo_info.new_record? ? @seo_info.save :  @seo_info.update_attributes(params[:seo_info])
    if ok
      redirect_to admin_admin_infoable_path(params[:type])
    else
      render :action => :edit_seo
    end
  end
  
  private
  def find_seo_infoable
    @element = params[:type].constantize.find(params[:id])    
  end
end