module Spotlight
  ##
  # Spotlight controller helpers
  module Controller
    extend ActiveSupport::Concern
    include Blacklight::Controller
    include Spotlight::Config

    included do
      helper_method :current_site, :current_exhibit, :current_masthead, :exhibit_masthead?, :resource_masthead?
    end

    def current_site
      @current_site ||= Spotlight::Site.instance
    end

    def current_exhibit
      @exhibit
    end

    def current_masthead
      @masthead ||= if resource_masthead?
                      # TODO: is there a way to get this generically, instead of requiring controllers
                      #  to override #current_masthead or set it explicitly?. In the meantime, `nil` is
                      #  hopefully less confusing than a wrong value.
                      nil
                    elsif current_exhibit
                      current_exhibit.masthead if exhibit_masthead?
                    else
                      current_site.masthead if current_site.masthead && current_site.masthead.display?
                    end
    end

    def current_masthead=(masthead)
      @masthead = masthead
    end

    def resource_masthead?
      false
    end

    def exhibit_masthead?
      current_exhibit && current_exhibit.masthead && current_exhibit.masthead.display?
    end

    # overwrites Blacklight::Controller#blacklight_config
    def blacklight_config
      if current_exhibit
        exhibit_specific_blacklight_config
      else
        default_catalog_controller.blacklight_config
      end
    end

    def search_action_url(*args)
      if current_exhibit
        exhibit_search_action_url(*args)
      else
        main_app.catalog_index_url(*args)
      end
    end

    def search_facet_url(*args)
      if current_exhibit
        exhibit_search_facet_url(*args)
      else
        main_app.catalog_facet_url(*args)
      end
    end

    def exhibit_search_action_url(*args)
      options = args.extract_options!
      only_path = options[:only_path]
      options.except! :exhibit_id, :only_path

      if only_path
        spotlight.exhibit_catalog_index_path(current_exhibit, *args, options)
      else
        spotlight.exhibit_catalog_index_url(current_exhibit, *args, options)
      end
    end

    def exhibit_search_facet_url(*args)
      options = args.extract_options!
      only_path = options[:only_path]
      options = params.merge(options).except(:exhibit_id, :only_path)

      if only_path
        spotlight.exhibit_catalog_facet_url(current_exhibit, *args, options)
      else
        spotlight.exhibit_catalog_facet_url(current_exhibit, *args, options)
      end
    end
  end
end
