# frozen_string_literal: true

module Spotlight
  # Enforce exhibit visibility for index queries
  module AccessControlsEnforcementSearchBuilder
    extend ActiveSupport::Concern

    included do
      self.default_processor_chain += %i[apply_permissive_visibility_filter apply_exhibit_resources_filter]
    end

    # Adds a filter that excludes resources that have been marked as not-visible
    def apply_permissive_visibility_filter(solr_params)
      return unless current_exhibit
      return if !blacklight_params[:public] && scope&.context&.key?(:current_ability) && scope.context[:current_ability].can?(:curate, current_exhibit)

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
      blacklight_config.current_exhibit
    end
  end
end
