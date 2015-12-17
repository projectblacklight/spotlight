module Spotlight
  # Create and update filters for an exhibit
  class ExhibitFiltersController < ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource :exhibit, class: 'Spotlight::Exhibit'
    load_and_authorize_resource through: :exhibit

    def create
      if @exhibit_filter.save
        flash[:notice] = t('helpers.submit.exhibit_filter.updated', model: @exhibit_filter.model_name.human)
      else
        flash[:alert] = @exhibit_filter.errors.full_messages.join('<br/>'.html_safe)
      end
      redirect_to spotlight.edit_exhibit_path @exhibit, anchor: 'filter'
    end

    def update
      unless @exhibit_filter.update(exhibit_filter_params)
        flash[:alert] = @exhibit_filter.errors.full_messages.join('<br/>'.html_safe)
      end
      redirect_to spotlight.edit_exhibit_path @exhibit, anchor: 'filter'
    end

    def exhibit_filter_params
      params.require(:exhibit_filter).permit(:exhibit_id, :field, :value)
    end
  end
end
