module Spotlight
  module AdminTitleHelper
    def curation_page_title title = nil
      page_title t(:'spotlight.curation.header'), title
    end

    def administration_page_title title = nil
      page_title t(:'spotlight.administration.header'), title
    end

    def page_title section, title = nil
      @page_title = t(:'spotlight.html_admin_title', section: section, title: title || t(:'.title', default: :'.header'), application_name: application_name)
      safe_join([content_tag(:h1, section), content_tag(:h2, title || t(:'.header'), class: 'text-muted')], "\n")
    end
  end
end