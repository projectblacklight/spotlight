module Spotlight
  module Concerns
    ##
    # Search context helpers
    module CatalogSearchContext
      protected

      # rubocop:disable Metrics/AbcSize
      def current_page_context
        @current_page_context ||= if current_search_session_from_home_page?
                                    current_exhibit.home_page if can? :read, current_exhibit.home_page
                                  elsif current_search_session_from_page?
                                    page_id = current_search_session.query_params['id']
                                    current_exhibit.pages.accessible_by(current_ability).find(page_id) if page_id
                                  end
      end
      # rubocop:enable Metrics/AbcSize

      def current_browse_category
        @current_browse_category ||= if current_search_session_from_browse_category?
                                       search_id = current_search_session.query_params['id']
                                       current_exhibit.searches.accessible_by(current_ability).find(search_id)
                                     end
      end

      def current_search_session_from_browse_category?
        current_search_session &&
          current_search_session.query_params['action'] == 'show' &&
          current_search_session.query_params['controller'] == 'spotlight/browse' &&
          current_search_session.query_params['id']
      end

      def current_search_session_from_page?
        current_search_session &&
          current_search_session.query_params['action'] == 'show' &&
          current_search_session.query_params['controller'].ends_with?('_pages')
      end

      def current_search_session_from_home_page?
        current_search_session &&
          current_search_session.query_params['action'] == 'show' &&
          current_search_session.query_params['controller'] == 'spotlight/home_pages'
      end
    end
  end
end
