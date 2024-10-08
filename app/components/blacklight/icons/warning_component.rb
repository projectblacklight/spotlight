# frozen_string_literal: true

module Blacklight
  module Icons
    # Icon for Warning
    class WarningComponent < Spotlight::IconComponent
      self.svg = <<~SVG
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
          <path d="M1 21h22L12 2 1 21zm12-3h-2v-2h2v2zm0-4h-2v-4h2v4z"/>
        </svg>
      SVG
    end
  end
end
