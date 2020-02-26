# frozen_string_literal: true

module Spotlight
  module Concerns
    ##
    # Search context helpers
    module CatalogSearchContext
      protected

      ##
      # Represents the current page referrer or from a search context
      def current_page_context
        @current_page_context ||= current_page_from_page_context if current_page_from_page?
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.debug "Unable to get current page context from #{current_search_session.inspect}: #{e}"
        nil
      end

      def current_browse_category
        @current_browse_category ||= if current_search_session_from_browse_category?
                                       search_id = current_search_session.query_params['id']
                                       current_exhibit.searches.accessible_by(current_ability).find(search_id)
                                     end
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.debug "Unable to get current page context from #{current_search_session.inspect}: #{e}"
        nil
      end

      def current_search_session_from_browse_category?
        current_search_session &&
          current_search_session.query_params['action'] == 'show' &&
          current_search_session.query_params['controller'] == 'spotlight/browse' &&
          current_search_session.query_params['id']
      end

      def current_page_from_page?
        page_referrer &&
          page_referrer[:action] == 'show' &&
          page_referrer[:controller].ends_with?('_pages')
      end

      def page_referrer
        Rails.application.routes.recognize_path(request.referrer)
      rescue ActionController::RoutingError => e
        Rails.logger.debug "Unable to build routing information. #{e.message}"
        nil
      end

      def current_page_from_page_context
        current_exhibit.pages.accessible_by(current_ability).find(page_referrer[:id])
      end
    end
  end
end
