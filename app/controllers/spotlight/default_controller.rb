module Spotlight
  class DefaultController < Spotlight::ApplicationController

    def index
      default = Spotlight::Exhibit.default
      redirect_to exhibit_home_page_path(default, default.home_page)
    end
  end
end

