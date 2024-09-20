# frozen_string_literal: true

module Blacklight
  module Icons
    # Icon for ChevronRight
    class ChevronRightComponent < Blacklight::Icons::IconComponent
      self.svg = <<~SVG
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
          <path fill="none" d="M0 0h24v24H0V0z"/>
          <path d="M10 6L8.59 7.41 13.17 12l-4.58 4.59L10 18l6-6-6-6z"/>
        </svg>
      SVG
    end
  end
end
