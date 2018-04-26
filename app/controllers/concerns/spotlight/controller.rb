module Spotlight
  ##
  # Spotlight controller helpers
  module Controller
    extend ActiveSupport::Concern
    include Blacklight::Controller
    include Spotlight::Config

    included do
      helper_method :current_site, :current_exhibit, :current_masthead, :exhibit_masthead?, :resource_masthead?
      before_action :set_exhibit_locale_scope, :set_locale
    end

    def set_exhibit_locale_scope
      Translation.current_exhibit = current_exhibit
    end

    def current_site
      @current_site ||= Spotlight::Site.instance
    end

    def current_exhibit
      @exhibit || (Spotlight::Exhibit.find(params[:exhibit_id]) if params[:exhibit_id].present?)
    end

    def current_masthead
      @masthead ||= if resource_masthead?
                      # TODO: is there a way to get this generically, instead of requiring controllers
                      #  to override #current_masthead or set it explicitly?. In the meantime, `nil` is
                      #  hopefully less confusing than a wrong value.
                      nil
                    elsif current_exhibit
                      current_exhibit.masthead if exhibit_masthead?
                    elsif current_site.masthead && current_site.masthead.display?
                      current_site.masthead
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

    def set_locale
      I18n.locale = params[:locale] || I18n.default_locale
    end

    def default_url_options
      return super unless current_exhibit
      return super if current_exhibit.languages.accessible_by(current_ability).none? || I18n.locale == I18n.default_locale

      super.merge(locale: I18n.locale)
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
        main_app.search_catalog_url(*args)
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
        spotlight.search_exhibit_catalog_path(current_exhibit, *args, options)
      else
        spotlight.search_exhibit_catalog_url(current_exhibit, *args, options)
      end
    end

    def exhibit_search_facet_url(*args)
      options = args.extract_options!
      options = Blacklight::Parameters.sanitize(params.to_unsafe_h.with_indifferent_access).merge(options).except(:exhibit_id, :only_path)
      spotlight.facet_exhibit_catalog_url(current_exhibit, *args, options)
    end
  end
end
