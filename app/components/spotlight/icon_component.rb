# frozen_string_literal: true

module Spotlight
  # Displays the document
  class IconComponent < Blacklight::Icons::IconComponent
    if Blacklight.version < '8.0'
      # Work around https://github.com/projectblacklight/blacklight/issues/3232 (fixed in Blacklight 8.0)
      def classes
        (@classes - ['blacklight-icons-'] + ["blacklight-icons-#{name}"]).uniq
      end
    end
  end
end
