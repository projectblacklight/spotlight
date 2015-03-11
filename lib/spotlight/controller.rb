module Spotlight
  module Controller
    extend ActiveSupport::Concern
    include Blacklight::Controller
    include Spotlight::Config

    included do
      helper_method :current_exhibit, :current_masthead, :current_search_masthead?
    end

    def current_exhibit
      @exhibit
    end

    def current_masthead
      [current_search.try(:masthead), current_exhibit.try(:masthead)].compact.select(&:display?).first
    end

    def current_search_masthead?
      current_search && current_search.masthead.try(:display?)
    end

    def current_search
      @search if @search.present? && params[:action] == 'show'
    end

    # overwrites Blacklight::Controller#blacklight_config
    def blacklight_config
      if current_exhibit
        exhibit_specific_blacklight_config
      else
        default_catalog_controller.blacklight_config
      end
    end

    def search_action_url *args
      if current_exhibit
        exhibit_search_action_url *args
      else
        main_app.catalog_index_url *args
      end
    end

    def search_facet_url *args
      if current_exhibit
        exhibit_search_facet_url *args
      else
        main_app.catalog_facet_url *args
      end
    end

    def exhibit_search_action_url *args
      options = args.extract_options!
      only_path = options[:only_path]
      options.except! :exhibit_id, :only_path

      if only_path
        spotlight.exhibit_catalog_index_path(current_exhibit, *args, options)
      else
        spotlight.exhibit_catalog_index_url(current_exhibit, *args, options)
      end
    end

    def exhibit_search_facet_url *args
      options = args.extract_options!
      only_path = options[:only_path]
      options.except! :exhibit_id, :only_path

      if only_path
        spotlight.exhibit_catalog_facet_url(current_exhibit, *args, options)
      else
        spotlight.exhibit_catalog_facet_url(current_exhibit, *args, options)
      end
    end
  end
end
