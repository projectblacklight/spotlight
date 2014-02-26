module Spotlight
  module TitleHelper
    def curation_page_title title = nil
      page_title t(:'spotlight.curation.header'), title
    end

    def administration_page_title title = nil
      page_title t(:'spotlight.administration.header'), title
    end

    def page_title section, title = nil
      set_html_page_title(t(:'spotlight.html_admin_title', section: section, title: title || t(:'.title', default: :'.header')))
      content_tag(:h1, safe_join([section, content_tag(:small, title || t(:'.header'))], "\n"), class: "page-header")
    end

    def set_html_page_title title = nil
      @page_title = t(:'spotlight.html_title', title: title || t(:'.title', default: :'.header'), application_name: application_name)
    end

    def header_with_count *args
      title, count = if args.length == 2
        args
      else
        [t(:'.header'), args.first]
      end

      safe_join([title, content_tag(:span, count, class: 'label label-default')], " ")
    end

  end
end