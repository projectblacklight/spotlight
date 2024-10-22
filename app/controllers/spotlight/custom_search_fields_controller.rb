# frozen_string_literal: true

module Spotlight
  # CRUD actions for exhibit custom search field management.
  class CustomSearchFieldsController < ApplicationController
    before_action :authenticate_user!

    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
    load_and_authorize_resource through: :exhibit
    before_action :attach_breadcrumbs, only: %i[new edit]

    # GET /custom_search_fields/new
    def new
      add_breadcrumb(t(:'helpers.action.spotlight/custom_search_field.create'), new_exhibit_custom_search_field_path(@exhibit))
    end

    # GET /custom_search_fields/1/edit
    def edit
      add_breadcrumb(@custom_search_field.label, edit_exhibit_custom_search_field_path(@custom_search_field.exhibit, @custom_search_field))
    end

    # POST /custom_search_fields
    def create
      @custom_search_field.attributes = custom_search_field_params
      @custom_search_field.exhibit = current_exhibit

      if @custom_search_field.save
        redirect_to edit_exhibit_search_configuration_path(@custom_search_field.exhibit),
                    notice: t(:'helpers.submit.custom_search_field.created', model: @custom_search_field.class.model_name.human.downcase)
      else
        render action: 'new'
      end
    end

    # PATCH/PUT /custom_search_fields/1
    def update
      if @custom_search_field.update(custom_search_field_params)
        redirect_to edit_exhibit_search_configuration_path(@custom_search_field.exhibit),
                    notice: t(:'helpers.submit.custom_search_field.updated', model: @custom_search_field.class.model_name.human.downcase)
      else
        render :edit
      end
    end

    def destroy
      @custom_search_field.destroy

      redirect_to edit_exhibit_search_configuration_path(@custom_search_field.exhibit),
                  notice: t(:'helpers.submit.custom_search_field.destroyed', model: @custom_search_field.class.model_name.human.downcase)
    end

    private

    def attach_breadcrumbs
      add_breadcrumb(t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), @exhibit)
      add_breadcrumb(t(:'spotlight.configuration.sidebar.header'), exhibit_dashboard_path(@exhibit))
      add_breadcrumb(t(:'spotlight.configuration.sidebar.search_configuration'), edit_exhibit_search_configuration_path(@exhibit))
    end

    # Only allow trusted parameters through.
    def custom_search_field_params
      params.require(:custom_search_field).permit(:slug, :field, :label)
    end
  end
end
