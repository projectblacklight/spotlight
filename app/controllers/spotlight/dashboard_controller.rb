require_dependency "spotlight/application_controller"

module Spotlight
  class DashboardController < Spotlight::ApplicationController
    before_filter :authenticate_user!
    load_resource :exhibit, class: Spotlight::Exhibit

    def index
    end
  end
end
