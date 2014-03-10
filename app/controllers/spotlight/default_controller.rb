module Spotlight
  class DefaultController < Spotlight::ApplicationController

    def index
      default = Spotlight::ExhibitFactory.default
      redirect_to exhibit_home_page_path(default, default.home_page)
    end
  end
end

