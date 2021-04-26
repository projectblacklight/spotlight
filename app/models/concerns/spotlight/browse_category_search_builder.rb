# frozen_string_literal: true

module Spotlight
  # Enforce exhibit visibility for index queries
  module BrowseCategorySearchBuilder
    extend ActiveSupport::Concern

    included do
      self.default_processor_chain = %i[apply_browse_category_defaults] +
                                     default_processor_chain +
                                     %i[fix_up_browse_category_defaults fix_up_browse_category_queries]
    end

    # Adds a filter that excludes resources that have been marked as not-visible
    def apply_browse_category_defaults(solr_params)
      return unless current_browse_category

      solr_params.merge!(browse_category_search_builder.to_hash)
    end

    def fix_up_browse_category_defaults(solr_params)
      return if current_browse_category.nil? || search_state.send(:sort_field_key).present?

      solr_params[:sort] = browse_category_search_builder.sort
    end

    def fix_up_browse_category_queries(solr_params)
      return unless solr_params.dig(:json, :query, :bool, :must) && blacklight_params[:q]

      # This replicates existing spotlight 2.x search behavior, more or less. It
      # doesn't take into account the possibility that the browse category query
      # could use a different search field (which.. doesn't have an existing UI
      # control.. and may require additional upstream work to properly encapsulate
      # the two query parameters)
      solr_params[:json][:query][:bool][:must].map! do |q|
        q.is_a?(String) ? { edismax: { query: q } } : q
      end
    end

    private

    def current_exhibit
      blacklight_config.current_exhibit
    end

    def current_browse_category
      return unless current_exhibit && blacklight_params[:browse_category_id].present?

      @current_browse_category ||= current_exhibit.searches.find(blacklight_params[:browse_category_id])
    end

    def browse_category_search_builder
      @browse_category_search_builder ||= begin
        search_builder = self.class.new(@processor_chain, @scope)
        search_builder.with(current_browse_category.query_params)
      end
    end
  end
end
