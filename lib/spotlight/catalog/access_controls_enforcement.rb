module Spotlight
  module Catalog
    ##
    # Enforce exhibit visibility for index queries
    module AccessControlsEnforcement
      extend ActiveSupport::Concern

      included do
        self.search_params_logic += [:apply_permissive_visibility_filter, :apply_exhibit_resources_filter]
      end

      protected

      def apply_permissive_visibility_filter(solr_params, _user_params)
        return unless current_exhibit
        return if respond_to?(:can?) && can?(:curate, current_exhibit)

        solr_params.append_filter_query "-#{Spotlight::SolrDocument.visibility_field(current_exhibit)}:false"
      end

      def apply_exhibit_resources_filter(solr_params, _user_params)
        return unless Spotlight::Engine.config.filter_resources_by_exhibit && current_exhibit

        current_exhibit.solr_data.each do |facet_field, values|
          Array(values).each do |value|
            solr_params.append_filter_query search_builder.send(:facet_value_to_fq_string, facet_field, value)
          end
        end
      end
    end
  end
end
