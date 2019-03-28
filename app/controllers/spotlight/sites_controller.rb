# frozen_string_literal: true

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

    def site_params
      params.require(:site).permit(
        :title,
        :subtitle,
        :theme,
        masthead_attributes: masthead_params,
        exhibits_attributes: [:id, :weight]
      )
    end

    def masthead_params
      [
        :display,
        :iiif_region,
        :iiif_tilesource
      ]
    end
  end
end
