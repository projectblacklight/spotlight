module Spotlight
  ##
  # CRUD actions for Blacklight sort fields
  class SortConfigurationsController < Spotlight::ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
    load_and_authorize_resource :blacklight_configuration, through: :exhibit, singleton: true, parent: false

    def show
      respond_to do |format|
        format.json do
          render json: @blacklight_configuration.default_blacklight_config.view.to_h.reject { |_k, v| v.if == false }.keys
        end
      end
    end

    def edit
      add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), @exhibit
      add_breadcrumb t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(@exhibit)
      add_breadcrumb t(:'spotlight.curation.sidebar.sort_fields'), edit_exhibit_sort_configuration_path(@exhibit)
    end

    def update
      if @blacklight_configuration.update(exhibit_params)
        flash[:notice] = t(:'helpers.submit.blacklight_configuration.updated', model: @blacklight_configuration.class.model_name.human.downcase)
        redirect_to edit_exhibit_sort_configuration_path(@exhibit)
      else
        render action: 'edit'
      end
    end

    private

    def exhibit_params
      params.require(:blacklight_configuration).permit(
        sort_fields: [exhibit_configuration_sort_params]
      )
    end

    def exhibit_configuration_sort_params
      @blacklight_configuration.blacklight_config.sort_fields.keys.each_with_object({}) do |element, result|
        result[element] = [:enabled, :label, :weight]
      end
    end
  end
end
