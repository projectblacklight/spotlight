module Spotlight
  ##
  # Global site configuration
  class SitesController < Spotlight::ApplicationController
    before_action :authenticate_user!
    before_action :load_site
    load_and_authorize_resource

    def edit; end

    def edit_exhibits; end

    def update
      if @site.update(site_params)
        @site.update_masthead(update_params)
        redirect_to exhibits_path, notice: t(:'helpers.submit.site.updated', model: @site.class.model_name.human.downcase)
      else
        flash[:alert] = @site.errors.full_messages.join('<br>'.html_safe)
        render action: :edit
      end
    end

    def tags
      authorize! :tag, @site

      respond_to do |format|
        format.json { render json: Spotlight::Exhibit.all_tags.map(&:name) }
      end
    end

    private

    def load_site
      @site ||= Spotlight::Site.instance
    end

    def update_params
      params.require(:site).require(:masthead_attributes).permit(masthead_params)
    end

    def site_params
      params.require(:site).permit(
        :title,
        :subtitle,
        :masthead_id,
        # masthead_attributes: masthead_params,
        exhibits_attributes: [:id, :weight]
      )
    end

    def masthead_params
      [
        :display,
        # :source,
        :iiif_region,
        :iiif_tilesource
        # :remote_image_url,
        # :document_global_id,
        # :image_crop_x, :image_crop_y, :image_crop_w, :image_crop_h
      ]
    end
  end
end
