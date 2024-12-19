# frozen_string_literal: true

module Spotlight
  # Draws the masthead
  class MastheadComponent < ViewComponent::Base
    def initialize(current_exhibit:, current_masthead:, resource_masthead:)
      @current_exhibit = current_exhibit
      @current_masthead = current_masthead
      @resource_masthead = resource_masthead
      super
    end

    attr_reader :current_exhibit, :current_masthead

    delegate :breadcrumbs, :masthead_heading_content, :masthead_subheading_content, to: :helpers

    def resource_masthead?
      @resource_masthead
    end

    def show_contact_form?
      helpers.show_contact_form? &&
        (current_exhibit.nil? || !current_page?(spotlight.new_exhibit_contact_form_path(current_exhibit)))
    end

    def masthead_navbar
      if current_exhibit
        render 'shared/exhibit_navbar'
      else
        render 'shared/site_navbar'
      end
    end

    def title
      content_for(:masthead) || masthead_heading_content
    end

    def title_and_subtitle
      render title_component.new(title:, subtitle: masthead_subheading_content)
    end

    def title_component
      Spotlight::Engine.config.spotlight.title_component
    end
  end
end
