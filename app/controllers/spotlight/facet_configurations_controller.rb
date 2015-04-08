module Spotlight
  ##
  # Curator configuration for facet fields
  class FacetConfigurationsController < Spotlight::ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
    load_and_authorize_resource :blacklight_configuration, through: :exhibit, singleton: true, parent: false

    include Blacklight::SearchHelper

    def edit
      add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), @exhibit
      add_breadcrumb t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(@exhibit)
      add_breadcrumb t(:'spotlight.curation.sidebar.search_facets'), edit_exhibit_facet_configuration_path(@exhibit)
      @fields = repository.send_and_receive('admin/luke', fl: '*', 'json.nl' => 'map')['fields']
    end

    def update
      if @blacklight_configuration.update(exhibit_params)
        flash[:notice] = t(:'helpers.submit.blacklight_configuration.updated', model: @blacklight_configuration.class.model_name.human.downcase)
        redirect_to edit_exhibit_facet_configuration_path(@exhibit)
      else
        render action: 'edit'
      end
    end

    protected

    # the luke request handler can return document counts, but the seem to be incorrect.
    # They seem to be for the whole index and they decrease after optimizing.
    # This method finds those counts by doing regular facet queries
    def alternate_count
      @alt_count ||= begin
        facet_fields = @blacklight_configuration.blacklight_config.facet_fields.reject { |_k, v| v.pivot || v.query }
        solr_resp = repository.search('facet.query' => facet_fields.map { |_key, fields| "#{fields.field}:[* TO *]" },
                                      'rows' => 0,
                                      'facet' => true)
        @alt_count = solr_resp['facet_counts']['facet_queries'].each_with_object({}) do |(key, val), alt_count|
          alt_count[key.split(/:/).first] = val
        end
      end
    end

    helper_method :alternate_count

    private

    def exhibit_params
      params.require(:blacklight_configuration).permit(
        facet_fields: [exhibit_configuration_facet_params]
      )
    end

    def exhibit_configuration_facet_params
      @blacklight_configuration.blacklight_config.facet_fields.keys.each_with_object({}) do |element, result|
        result[element] = [:show, :label, :weight]
      end
    end
  end
end
