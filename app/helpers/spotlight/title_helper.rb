# frozen_string_literal: true

module Spotlight
  ##
  # Page title helpers
  module TitleHelper
    def curation_page_title(title = nil)
      page_title t(:'spotlight.curation.header'), title
    end

    def accessibility_page_title(title = nil)
      page_title t(:'spotlight.accessibility.header'), title
    end

    def configuration_page_title(title = nil)
      page_title t(:'spotlight.configuration.header'), title
    end

    def page_title(section, title = nil)
      title ||= t(:'.header', default: '').presence

      head_content = t(:'spotlight.html_admin_title', section:, title:) if section && title
      head_content ||= section || title
      set_html_page_title(head_content)

      html_content = safe_join([
        section.presence,
        (content_tag(:small, title) if title.present?)
      ].compact, "\n")

      content_tag(:h1, html_content, class: 'page-header')
    end

    def set_html_page_title(title = nil)
      @page_title = strip_tags(t(:'spotlight.html_title', title: title || t(:'.title', default: :'.header'), application_name:)).html_safe
    end
  end
end
