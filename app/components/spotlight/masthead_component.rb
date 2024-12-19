# frozen_string_literal: true

module Spotlight
  # Draws the masthead
  class MastheadComponent < ViewComponent::Base
    def initialize(current_exhibit:)
      @current_exhibit = current_exhibit
      super
    end

    attr_reader :current_exhibit

    def show_contact_form?
      helpers.show_contact_form? &&
        (current_exhibit.nil? || !current_page?(spotlight.new_exhibit_contact_form_path(current_exhibit)))
    end

    def masthead_navbar
      @masthead_navbar ||= capture do
        content_for? :masthead_navbar
          content_for :masthead_navbar
        elsif current_exhibit
          render 'shared/exhibit_navbar'
        else
          render 'shared/site_navbar'
        end
      end
    end
  end
end
