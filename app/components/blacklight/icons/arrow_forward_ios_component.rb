# frozen_string_literal: true

module Blacklight
  module Icons
    # Icon for ArrowForwardIos
    class ArrowForwardIosComponent < Spotlight::IconComponent
      self.svg = <<~SVG
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
          <path opacity=".87" fill="none" d="M24 24H0V0h24v24z"/>
          <path d="M6.49 20.13l1.77 1.77 9.9-9.9-9.9-9.9-1.77 1.77L14.62 12l-8.13 8.13z"/>
        </svg>
      SVG
    end
  end
end
