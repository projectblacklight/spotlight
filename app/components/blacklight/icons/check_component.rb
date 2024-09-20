# frozen_string_literal: true

module Blacklight
  module Icons
    # Icon for Check
    class CheckComponent < Blacklight::Icons::IconComponent
      self.svg = <<~SVG
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
          <path fill="none" d="M0 0h24v24H0V0z"/>
          <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41L9 16.17z"/>
        </svg>
      SVG
    end
  end
end
