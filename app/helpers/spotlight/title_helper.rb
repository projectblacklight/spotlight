# frozen_string_literal: true

module Spotlight
  ##
  # Page title helpers
  module TitleHelper
    def curation_page_title(title = nil)
      page_title t(:'spotlight.curation.header'), title
    end

    def configuration_page_title(title = nil)
      page_title t(:'spotlight.configuration.header'), title
    end

    def page_title(section, title = nil)
      set_html_page_title(t(:'spotlight.html_admin_title', section: section, title: title || t(:'.title', default: :'.header')))
      content_tag(:h1, safe_join([section, content_tag(:small, title || t(:'.header'))], "\n"), class: 'page-header')
    end

    # rubocop:disable Naming/AccessorMethodName
    def set_html_page_title(title = nil)
      @page_title = strip_tags(t(:'spotlight.html_title', title: title || t(:'.title', default: :'.header'), application_name: application_name)).html_safe
    end
    # rubocop:enable Naming/AccessorMethodName
  end
end
