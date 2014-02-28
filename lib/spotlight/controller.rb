module Spotlight
  module Controller
    extend ActiveSupport::Concern

    included do
      helper_method :current_exhibit
    end

    def current_exhibit
      @exhibit ||= Spotlight::Exhibit.default
    end

  end
end
