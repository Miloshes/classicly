class MobileAppUpsellRedirectsController < ApplicationController

  def index
    if params[:experiment].blank? || params[:source].blank?
      render "shared/_not_found.html", status: 404
    end

    finished(params[:experiment])
    redirect_to APP_CONFIG["mobile_app_upsell_redirect_urls"][params[:source]]
  end

end
