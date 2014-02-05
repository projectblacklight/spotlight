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

    def new_spotlight_page_path_for(exhibit, model=page_model)
      spotlight.send(:"new_exhibit_#{model}_path", exhibit)
    end

    def update_pages_path(exhibit, model=page_model)
      model == 'feature_page' ? update_all_exhibit_feature_pages_path(exhibit) : update_all_exhibit_about_pages_path(exhibit)
    end

    private

    def main_app_url_helper?(method)
        (method.to_s.end_with?('_path') or method.to_s.end_with?('_url')) and
        main_app.respond_to?(method)
    end
  end
end
