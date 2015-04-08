module Spotlight
  class BlacklightConfigurationsController < Spotlight::ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
    load_and_authorize_resource through: :exhibit, singleton: true

    include Blacklight::SearchHelper

    def update
      if @blacklight_configuration.update(exhibit_params)
        flash[:notice] = t(:'helpers.submit.blacklight_configuration.updated', model: @blacklight_configuration.class.model_name.human.downcase)
      end

      case
      when params[:blacklight_configuration][:index_fields]
        redirect_to exhibit_edit_metadata_path(@exhibit)
      when params[:blacklight_configuration][:facet_fields]
        redirect_to exhibit_edit_facets_path(@exhibit)
      when params[:blacklight_configuration][:sort_fields]
        redirect_to exhibit_edit_sort_fields_path(@exhibit)
      else
        redirect_to exhibit_dashboard_path(@exhibit)
      end
    end

    def metadata_fields
      respond_to do |format|
        format.json do
          render json: @blacklight_configuration.blacklight_config.index_fields.as_json
        end
      end
    end

    def available_search_views
      respond_to do |format|
        format.json do
          render json: @blacklight_configuration.default_blacklight_config.view.to_h.reject { |_k, v| v.if == false }.keys
        end
      end
    end

    ##
    # Edit the index and show view metadata fields
    def edit_metadata_fields
      add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), @exhibit
      add_breadcrumb t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(@exhibit)
      add_breadcrumb t(:'spotlight.curation.sidebar.metadata'), exhibit_edit_metadata_path(@exhibit)
    end

    ##
    # Edit the index and show view metadata fields
    def edit_facet_fields
      add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), @exhibit
      add_breadcrumb t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(@exhibit)
      add_breadcrumb t(:'spotlight.curation.sidebar.search_facets'), exhibit_edit_facets_path(@exhibit)
      @fields = repository.send_and_receive('admin/luke', fl: '*', 'json.nl' => 'map')['fields']
    end

    ##
    # Edit the index and show view metadata fields
    def edit_sort_fields
      add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), @exhibit
      add_breadcrumb t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(@exhibit)
      add_breadcrumb t(:'spotlight.curation.sidebar.sort_fields'), exhibit_edit_sort_fields_path(@exhibit)
    end

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

    protected

    def exhibit_params
      params.require(:blacklight_configuration).permit(
        facet_fields: [exhibit_configuration_facet_params],
        index_fields: [exhibit_configuration_index_params],
        sort_fields: [exhibit_configuration_sort_params]
      )
    end

    def exhibit_configuration_index_params
      views = @blacklight_configuration.default_blacklight_config.view.keys | [:show]

      @blacklight_configuration.blacklight_config.index_fields.keys.each_with_object({}) do |element, result|
        result[element] = ([:enabled, :label, :weight] | views)
      end
    end

    def exhibit_configuration_facet_params
      @blacklight_configuration.blacklight_config.facet_fields.keys.each_with_object({}) do |element, result|
        result[element] = [:show, :label, :weight]
      end
    end

    def exhibit_configuration_sort_params
      @blacklight_configuration.blacklight_config.sort_fields.keys.each_with_object({}) do |element, result|
        result[element] = [:enabled, :label, :weight]
      end
    end
  end
end
