module Spotlight
  # Create and update filters for an exhibit
  class FiltersController < ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource :exhibit, class: 'Spotlight::Exhibit'
    load_and_authorize_resource through: :exhibit

    def create
      if @filter.save
        flash[:notice] = t('helpers.submit.filter.updated', model: @filter.model_name.human)
      else
        flash[:alert] = @filter.errors.full_messages.join('<br/>'.html_safe)
      end
      redirect_to spotlight.edit_exhibit_path @exhibit, anchor: 'filter'
    end

    def update
      unless @filter.update(filter_params)
        flash[:alert] = @filter.errors.full_messages.join('<br/>'.html_safe)
      end
      redirect_to spotlight.edit_exhibit_path @exhibit, anchor: 'filter'
    end

    def filter_params
      params.require(:filter).permit(:field, :value)
    end
  end
end
