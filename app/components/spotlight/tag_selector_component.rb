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
      @all_tags = all_tags&.sort_by { |tag| tag.name.downcase }

      super
    end

    def selected_tags
      selected_tags_value.split(',').map(&:strip)
    end

    def close_button_html
      # If we remove Bootstrap 4 support, we can remove this.
      bootstrap4? ? '&times;' : ''
    end

    # If we remove Blacklight 7 or Bootstrap 4 support, we can remove this and use one of the built-ins.
    def search_icon_svg
      <<~SVG
        <svg xmlns="http://www.w3.org/2000/svg" fill="currentColor" aria-hidden="true" width="24" height="24" viewBox="0 0 24 24">
          <path fill="none" d="M0 0h24v24H0V0z"/><path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/>
        </svg>
      SVG
    end

    private

    def bootstrap_version
      bootstrap_gem = Gem.loaded_specs['bootstrap']
      bootstrap_gem&.version&.to_s
    end

    def bootstrap4?
      bootstrap_version&.start_with?('4')
    end

    # To pass to the JS
    def translation_data
      {
        add_new_tag: t('.add_new_tag'),
        remove: t('.remove'),
        selected_tags: t('.selected_tags')
      }
    end

    def selected?(tag)
      selected_tags.include?(tag.name)
    end

    attr_reader :form, :field_name, :selected_tags_value, :all_tags
  end
end
