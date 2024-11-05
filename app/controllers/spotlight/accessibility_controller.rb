# frozen_string_literal: true

module Spotlight
  ##
  # Exhibit dashboard controller
  class AccessibilityController < Spotlight::ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit

    include Spotlight::Base
    include Spotlight::SearchHelper

    def alt_text
      authorize! :curate, @exhibit

      @limit = 5
      # Sort by newest except for the homepage, which is always first
      pages_with_alt = @exhibit.pages.order(Arel.sql('id = 1 DESC, created_at DESC')).select { |elem| elem.content.any?(&:alt_text?) }
      pages = params[:show_all] ? pages_with_alt : pages_with_alt.first(@limit)
      @pages = pages.map { |page| get_alt_info(page) }
      @has_alt_text = @pages.sum { |page| page[:has_alt_text] }
      @total_alt_items = @pages.sum { |page| page[:can_have_alt_text] }

      attach_alt_text_breadcrumbs
    end

    private

    def get_alt_info(page)
      can_have_alt_text = 0
      has_alt_text = 0
      page.content.each do |content|
        content.item&.each_value do |item|
          next if item['alt_text_backup'].nil?

          can_have_alt_text += 1
          has_alt_text += 1 if item['alt_text'].present? || item['decorative'].present?
        end
      end
      { can_have_alt_text:, has_alt_text:, page: }
    end

    def attach_alt_text_breadcrumbs
      add_breadcrumb(t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), @exhibit)
      add_breadcrumb(t(:'spotlight.accessibility.header'), exhibit_dashboard_path(@exhibit))
      add_breadcrumb(t(:'spotlight.accessibility.alt_text.header'), exhibit_alt_text_path(@exhibit))
    end
  end
end
