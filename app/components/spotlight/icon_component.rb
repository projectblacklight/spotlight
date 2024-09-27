# frozen_string_literal: true

module Spotlight
  # Displays the document
  class IconComponent < Blacklight::Icons::IconComponent
    if Blacklight.version < '7.39'
      # Work around https://github.com/projectblacklight/blacklight/issues/3232 (fixed in Blacklight 7.39)
      def classes
        ((@classes || (super if defined?(super)) || []) - ['blacklight-icons-'] + ["blacklight-icons-#{name}"]).uniq
      end
    end
  end
end
