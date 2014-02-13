module Spotlight
  module ApplicationHelper

    # search_action_url is a special Blacklight helper (not a route),
    # so it doesn't get caught by the method_missing logic below.
    # TODO: we should consider making this configurable
    def search_action_url *args
      if controller_path == 'spotlight/catalog'
        catalog_index_url *args
      else
        main_app.catalog_index_url *args
      end
    end

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

    private

    def main_app_url_helper?(method)
        (method.to_s.end_with?('_path') or method.to_s.end_with?('_url')) and
        main_app.respond_to?(method)
    end
  end
end
