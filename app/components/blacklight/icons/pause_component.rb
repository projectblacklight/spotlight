# frozen_string_literal: true

module Blacklight
  module Icons
    # Icon for Pause
    class PauseComponent < Blacklight::Icons::IconComponent
      self.svg = <<~SVG
        <svg xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 0 24 24" width="24" fill="currentColor">
          <path d="M0 0h24v24H0z" fill="none"/>
          <path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/>
        </svg>
      SVG
    end
  end
end
