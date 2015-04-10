module Spotlight
  ##
  # Administration for Blacklight view configurations
  class ViewConfigurationsController < Spotlight::ApplicationController
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
  end
end
