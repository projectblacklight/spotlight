# frozen_string_literal: true

module Spotlight
  # Displays a tag selection input
  # This uses a plain text input that acts-as-taggable-on expects.
  class TagSelectorComponent < ViewComponent::Base
    # selected_tags_value is a comma delimited string of tags
    def initialize(field_name:, all_tags:, selected_tags_value: nil, form: nil)
      @form = form
      @field_name = field_name
      @selected_tags_value = selected_tags_value || ''
      @all_tags = all_tags&.sort_by { |tag| (tag.respond_to?(:name) ? tag.name : tag).downcase }

      super()
    end

    def selected_tags
      selected_tags_value.split(',').map(&:strip)
    end

    def search_icon_svg
      render Blacklight::Icons::SearchComponent.new
    end

    private

    # To pass to the JS
    def translation_data
      {
        add_new_tag: t('.add_new_tag'),
        remove: t('.remove')
      }
    end

    def selected?(tag)
      selected_tags.include?(tag.respond_to?(:name) ? tag.name : tag)
    end

    attr_reader :form, :field_name, :selected_tags_value, :all_tags
  end
end
