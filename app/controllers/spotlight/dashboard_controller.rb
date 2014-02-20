require_dependency "spotlight/application_controller"

module Spotlight
  class DashboardController < Spotlight::ApplicationController
    before_filter :authenticate_user!
    load_resource :exhibit, class: Spotlight::Exhibit #TODO authorize user?

    def index
      add_breadcrumb @exhibit.title, @exhibit
      add_breadcrumb t(:'spotlight.curation.sidebar.dashboard'), exhibit_dashboard_path(@exhibit)
    end
  end
end
