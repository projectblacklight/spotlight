module Spotlight
  ##
  # Edit and update an exhibit's appearance
  class AppearancesController < Spotlight::ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource id_param: :exhibit_id, instance_name: 'exhibit', class: 'Spotlight::Exhibit', parent: false

    def update
      if @exhibit.update(exhibit_params)
        # Update masthead attributes, only after we have saved the masthead_id
        update_masthead
        # Update thumbnail attributes, only after we have saved the thumbnail_id
        update_thumbnail

        notice = t(:'helpers.submit.spotlight_default.updated', model: @exhibit.class.model_name.human.downcase)
        redirect_to edit_exhibit_appearance_path(@exhibit), notice: notice
      else
        render 'edit'
      end
    end

    def edit
      add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), @exhibit
      add_breadcrumb t(:'spotlight.configuration.sidebar.header'), exhibit_dashboard_path(@exhibit)
      add_breadcrumb t(:'spotlight.configuration.sidebar.appearance'), edit_exhibit_appearance_path(@exhibit)
    end

    protected

    def update_masthead
      return unless @exhibit.masthead
      @exhibit.masthead.update(params.require(:exhibit).require(:masthead_attributes).permit(featured_image_params))
    end

    def update_thumbnail
      return unless @exhibit.thumbnail
      @exhibit.thumbnail.update(params.require(:exhibit).require(:thumbnail_attributes).permit(featured_image_params))
    end

    def exhibit_params
      params.require(:exhibit).permit(:masthead_id,
                                      :thumbnail_id,
                                      main_navigations_attributes: [:id, :display, :label, :weight])
    end

    def featured_image_params
      [
        :iiif_url,
        :display,
        :source,
        :image,
        :remote_image_url,
        :document_global_id,
        # :image_crop_x, :image_crop_y, :image_crop_w, :image_crop_h
      ]
    end
  end
end
