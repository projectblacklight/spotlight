module Spotlight
  module Base
    extend ActiveSupport::Concern

    include Blacklight::Base
    include Spotlight::Config

    def blacklight_config
      @blacklight_config ||= exhibit_specific_blacklight_config
    end

  end
end