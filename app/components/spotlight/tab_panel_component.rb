# frozen_string_literal: true

module Spotlight
  # Component for building out a basic tabbed interface
  class TabPanelComponent < ViewComponent::Base
    renders_many :tabs, Spotlight::TabComponent

    def initialize(tab_position: :inside)
      super
      @tab_position = tab_position
    end
  end
end
