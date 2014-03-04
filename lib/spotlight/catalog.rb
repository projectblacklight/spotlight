module Spotlight
  module Catalog
    extend ActiveSupport::Concern
    include Blacklight::Catalog
    include Spotlight::Base

    require 'spotlight/catalog/access_controls_enforcement'

    include Spotlight::Catalog::AccessControlsEnforcement

  end
end
