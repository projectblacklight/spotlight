# frozen_string_literal: true

module Blacklight
  module Icons
    # Icon for ArrowBackIos
    class ArrowBackIosComponent < Spotlight::IconComponent
      self.svg = <<~SVG
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
          <path opacity=".87" fill="none" d="M0 0h24v24H0V0z"/>
          <path d="M17.51 3.87L15.73 2.1 5.84 12l9.9 9.9 1.77-1.77L9.38 12l8.13-8.13z"/>
        </svg>
      SVG
    end
  end
end
