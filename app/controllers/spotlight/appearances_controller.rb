# frozen_string_literal: true

module Spotlight
  ##
  # Edit and update an exhibit's appearance
  class AppearancesController < Spotlight::ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource id_param: :exhibit_id, instance_name: 'exhibit', class: 'Spotlight::Exhibit', parent: false

    def edit
      add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), @exhibit
      add_breadcrumb t(:'spotlight.configuration.sidebar.header'), exhibit_dashboard_path(@exhibit)
      add_breadcrumb t(:'spotlight.configuration.sidebar.appearance'), edit_exhibit_appearance_path(@exhibit)
    end

    def update
      if @exhibit.update(exhibit_params)
        notice = t(:'helpers.submit.spotlight_default.updated', model: @exhibit.class.model_name.human.downcase)
        redirect_to edit_exhibit_appearance_path(@exhibit), notice: notice
      else
        render 'edit'
      end
    end

    protected

    def exhibit_params
      params.require(:exhibit).permit(:theme,
                                      main_navigations_attributes: %i[id display label weight],
                                      masthead_attributes: featured_image_params,
                                      thumbnail_attributes: featured_image_params)
    end
  end
end
