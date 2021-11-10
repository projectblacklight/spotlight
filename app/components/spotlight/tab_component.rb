# frozen_string_literal: true

module Spotlight
  # Component for a single tab panel pane, with responsibility for also building
  # out the tab panel's control
  class TabComponent < ViewComponent::Base
    def initialize(id:, label:, active: false, label_data: {})
      super

      @id = id
      @label = label
      @active = active
      @classes = ['tab-pane', ('active' if active)].compact
      @label_data = label_data
    end

    def render_label
      tag.li role: 'presentation', class: 'nav-item' do
        link_to @label,
                "##{@id}",
                aria: {
                  controls: @id
                },
                role: 'tab',
                data: { toggle: 'tab' }.merge(@label_data),
                class: ['nav-link', ('active' if @active)].compact.join(' ')
      end
    end
  end
end
