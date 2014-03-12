module Spotlight
  class DefaultController < Spotlight::ApplicationController

    def index
      default = Spotlight::Exhibit.default
      redirect_to exhibit_root_path(default)
    end
  end
end
