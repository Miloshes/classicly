class Admin::AdminSeoController < Admin::BaseController
  def admin_infoable
    @type = params[:type]
    klass = @type.classify.constantize
    if params[:search]
      @elements = klass.search(params[:search], params[:page], 25)
    else
      @elements = klass.page(params[:page]).per(25)
    end
  end

  def edit_seo
    @element = params[:type].constantize.find(params[:id])
    @seo_info = @element.seo_info || SeoInfo.new
  end

  def main
    
  end
  
  def update_seo_info
    @element = params[:type].constantize.find(params[:id])
    @seo_info = @element.seo_info || @element.build_seo_info(params[:seo_info])
    res = @seo_info.new_record? ? @seo_info.save :  @seo_info.update_attributes(params[:seo_info])
    if res
      redirect_to admin_admin_infoable_path(params[:type])
    else
      render :action => :edit_seo
    end
  end
end