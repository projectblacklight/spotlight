module Spotlight
  module ApplicationHelper
    include CrudLinkHelpers

    # Can search for named routes directly in the main app, omitting
    # the "main_app." prefix
    def method_missing method, *args, &block
      if main_app_url_helper?(method)
        main_app.send(method, *args)
      else
        super
      end
    end

    def respond_to?(method)
      main_app_url_helper?(method) or super
    end

    def url_for_document document
      return nil if document.nil?

      if current_exhibit
        spotlight.exhibit_catalog_path(current_exhibit, document)
      else
        document
      end
    end

    def curation_mode_label_class
      if curation_mode?
        "warning"
      else
        "primary"
      end
    end

    def curation_mode?
      params[:action] == "edit"
    end

    def url_to_tag_facet tag
      if current_exhibit
        search_action_url(add_facet_params(Spotlight::SolrDocument.solr_field_for_tagger(current_exhibit), tag, {}))
      else
        search_action_url(q: tag)
      end
    end

    def curation_page_title title = nil
      page_title t(:'spotlight.curation.header'), title

    end

    def administration_page_title title = nil
      page_title t(:'spotlight.administration.header'), title
    end

    def page_title section, title = nil
      @page_title = t(:'spotlight.html_admin_title', section: section, title: title || t(:'.title', default: :'.header'), application_name: application_name)
      content_tag(:h1, section) + content_tag(:h2, title || t(:'.header'), class: 'text-muted')
    end

    private


    def main_app_url_helper?(method)
        (method.to_s.end_with?('_path') or method.to_s.end_with?('_url')) and
        main_app.respond_to?(method)
    end
  end
end
