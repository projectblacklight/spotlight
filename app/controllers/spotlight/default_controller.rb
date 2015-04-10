module Spotlight
  ##
  # Shim controller to redirect engine root requests to
  # an exhibit root
  class DefaultController < Spotlight::ApplicationController
    def index
      default = Spotlight::Exhibit.default
      redirect_to exhibit_root_path(default)
    end
  end
end
