module Spotlight
  module Catalog
    ##
    # Enforce exhibit visibility for index queries
    module AccessControlsEnforcement
      extend ActiveSupport::Concern

      included do
        self.search_params_logic += [:apply_permissive_visibility_filter, :apply_exhibit_resources_filter]
      end

      ##
      # SearchBuilder mixin
      module SearchBuilder
        extend ActiveSupport::Concern

        included do
          self.default_processor_chain += [:apply_permissive_visibility_filter, :apply_exhibit_resources_filter]
        end

        # Adds a filter that excludes resources that have been marked as not-visible
        def apply_permissive_visibility_filter(solr_params)
          return unless current_exhibit
          return if scope.respond_to?(:can?) && scope.can?(:curate, current_exhibit) && !blacklight_params[:public]

          solr_params.append_filter_query "-#{blacklight_config.document_model.visibility_field(current_exhibit)}:false"
        end

        def apply_exhibit_resources_filter(solr_params)
          return unless current_exhibit

          current_exhibit.solr_data.each do |facet_field, values|
            Array(values).each do |value|
              solr_params.append_filter_query send(:facet_value_to_fq_string, facet_field, value)
            end
          end
        end

        private

        def current_exhibit
          scope.current_exhibit
        end
      end
    end
  end
end
