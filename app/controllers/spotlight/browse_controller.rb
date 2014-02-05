module Spotlight
  class BrowseController < Spotlight::ApplicationController
    load_resource :exhibit, class: "Spotlight::Exhibit", only: [:index]
    load_resource class: "Spotlight::Search", only: [:show]

    def index

    end

    def show

    end
  end
end