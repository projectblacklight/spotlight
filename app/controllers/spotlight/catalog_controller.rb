# frozen_string_literal: true

module Spotlight
  ##
  # Spotlight's catalog controller. Note that this subclasses
  # the host application's CatalogController to get its configuration,
  # partial overrides, etc
  # rubocop:disable Metrics/ClassLength
  class CatalogController < ::CatalogController
    include Spotlight::Concerns::ApplicationController

    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit, prepend: true
    include Blacklight::Catalog
    include Spotlight::Catalog
    include Spotlight::Concerns::CatalogSearchContext

    before_action :authenticate_user!, only: %i[admin edit make_public make_private]
    before_action :check_authorization, only: %i[admin edit make_public make_private]
    before_action :redirect_to_exhibit_home_without_search_params!, only: :index

    before_action :attach_breadcrumbs
    before_action :add_breadcrumb_with_search_params, only: :index

    before_action :load_document, only: %i[edit update make_private make_public manifest]

    before_action only: :show do
      # Substitute the default document component with the custom one for Blacklight 8,
      # and add the necessary partials for Blacklight 7 (if they haven't configured the document component)
      if blacklight_config.show.document_component.nil? || blacklight_config.show.document_component == Blacklight::DocumentComponent
        if Blacklight::VERSION > '8'
          blacklight_config.show.document_component = Spotlight::DocumentComponent
        else
          blacklight_config.show.partials.unshift 'tophat'
          blacklight_config.show.partials.unshift 'curation_mode_toggle'
        end
      end
    end

    before_action only: :admin do
      blacklight_config.view.select! { |k, _v| k == :admin_table }
      unless blacklight_config.view.key? :admin_table
        blacklight_config.view.admin_table(document_component: Spotlight::DocumentAdminTableComponent,
                                           partials: [:index_compact],
                                           document_actions: [])
      end
      blacklight_config.view.admin_table.document_component ||= Spotlight::DocumentAdminTableComponent

      if Blacklight::VERSION > '8'
        blacklight_config.track_search_session.storage = false
      else
        blacklight_config.track_search_session = false
      end

      unless blacklight_config.sort_fields.key? :timestamp
        blacklight_config.add_sort_field :timestamp, default: true,
                                                     sort: "#{blacklight_config.index.timestamp_field} desc"
      end
    end

    before_action only: :edit do
      blacklight_config.action_mapping.edit.top_level_config = :show
    end

    def show
      super

      authenticate_user! && authorize!(:curate, current_exhibit) if @document.private? current_exhibit

      add_document_breadcrumbs(@document)
    end

    # "id_ng" and "full_title_ng" should be defined in the Solr core's schema.xml.
    # It's expected that these fields will be set up to have  EdgeNGram filter
    # setup within their index analyzer. This will ensure that this method returns
    # results when a partial match is passed in the "q" parameter.
    def autocomplete
      @response, = search_service.search_results do |builder|
        builder.with(builder.blacklight_params.merge(search_field: Spotlight::Engine.config.autocomplete_search_field, public: true, rows: 100))
      end

      respond_to do |format|
        format.json do
          render json: { docs: autocomplete_json_response(@response.documents) }
        end
      end
    end

    def admin
      add_breadcrumb(t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(@exhibit))
      add_breadcrumb(t(:'spotlight.curation.sidebar.items'), admin_exhibit_catalog_path(@exhibit))
      (@response,) = search_service.search_results
      @filters = params[:f] || []

      respond_to do |format|
        format.html
      end
    end

    def edit; end

    def update
      @document.update(current_exhibit, solr_document_params)
      @document.save

      try_solr_commit!

      redirect_to polymorphic_path([current_exhibit, @document])
    end

    def make_private
      @document.make_private!(current_exhibit)
      @document.save

      respond_to do |format|
        format.html { redirect_back(fallback_location: [spotlight, current_exhibit, @document]) }
        format.json { render json: true }
      end
    end

    def make_public
      @document.make_public!(current_exhibit)
      @document.save

      respond_to do |format|
        format.html { redirect_back(fallback_location: [spotlight, current_exhibit, @document]) }
        format.json { render json: true }
      end
    end

    def manifest
      if @document.uploaded_resource?
        render json: Spotlight::IiifManifestPresenter.new(@document, self).iiif_manifest_json
      else
        head :not_found
      end
    end

    protected

    def load_document
      result = search_service.fetch params[:id]

      @document = if result.is_a?(Array)
                    result.last
                  else
                    result
                  end
    end

    def attach_breadcrumbs
      if view_context.current_page?({ action: :admin })
        add_breadcrumb(t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), exhibit_root_path(@exhibit))
      else
        # When not on the admin page, get the translated value for the "Home" breadcrumb
        add_breadcrumb(t(:'spotlight.curation.nav.home', title: @exhibit.title), exhibit_root_path(@exhibit))
      end
    end

    ##
    # Override Blacklight's #setup_next_and_previous_documents to handle
    # browse categories too
    def setup_next_and_previous_documents
      if current_search_session_from_browse_category?
        setup_next_and_previous_documents_from_browse_category if current_browse_category
      elsif current_search_session_from_page? || current_search_session_from_home_page?
        # TODO: figure out how to construct previous/next documents
      else
        super
      end
    end

    def setup_next_and_previous_documents_from_browse_category
      index = search_session['counter'].to_i - 1
      response, documents = search_service.previous_and_next_documents_for_search index, current_browse_category.query_params.with_indifferent_access

      return unless response

      search_session['total'] = response.total
      @previous_document = documents.first
      @next_document = documents.last
    end

    def _prefixes
      @_prefixes ||= super + ['catalog']
    end

    ##
    # Admin catalog controller should not create a new search
    # session in the blacklight context
    def start_new_search_session?
      super || params[:action] == 'admin'
    end

    def solr_document_params
      params.require(:solr_document).permit(:exhibit_tag_list,
                                            uploaded_resource: [:url],
                                            sidecar: [:public, { data: [editable_solr_document_params] }])
    end

    def editable_solr_document_params
      custom_field_params + uploaded_resource_params
    end

    def uploaded_resource_params
      if @document.uploaded_resource?
        [{ configured_fields: Spotlight::Resources::Upload.fields(current_exhibit).map(&:field_name) }]
      else
        []
      end
    end

    def custom_field_params
      current_exhibit.custom_fields.as_strong_params
    end

    def check_authorization
      authorize! :curate, @exhibit
    end

    def redirect_to_exhibit_home_without_search_params!
      redirect_to spotlight.exhibit_root_path(@exhibit) unless has_search_parameters?
    end

    def has_search_parameters? # rubocop:disable Naming/PredicateName
      super || params[:browse_category_id].present?
    end

    def add_breadcrumb_with_search_params
      return unless has_search_parameters?

      add_breadcrumb(t(:'spotlight.catalog.breadcrumb.index'), spotlight.search_exhibit_catalog_path(params.to_unsafe_h), current: action_name == 'index')
    end

    # rubocop:disable Metrics/AbcSize
    def add_document_breadcrumbs(document)
      if current_browse_category
        add_breadcrumb(current_browse_category.exhibit.main_navigations.browse.label_or_default, exhibit_browse_index_path(current_browse_category.exhibit))
        add_breadcrumb(current_browse_category.title, exhibit_browse_path(current_browse_category.exhibit, current_browse_category))
      elsif current_page_context&.title&.present? && !current_page_context.is_a?(Spotlight::HomePage)
        add_breadcrumb(current_page_context.title, [current_page_context.exhibit, current_page_context])
      elsif current_search_session && !current_page_context&.is_a?(Spotlight::HomePage)
        add_breadcrumb(t(:'spotlight.catalog.breadcrumb.index'), search_action_url(current_search_session.query_params))
      end

      add_breadcrumb(view_context.document_presenter(document).heading, polymorphic_path([current_exhibit, document]))
    end
    # rubocop:enable Metrics/AbcSize

    def additional_export_formats(document, format)
      super

      format.solr_json do
        authorize! :update_solr, @exhibit
        render json: document.to_solr.merge(@exhibit.solr_data)
      end
    end

    def try_solr_commit!
      repository.connection.commit
    rescue StandardError => e
      Rails.logger.info "Failed to commit document updates: #{e}"
    end
  end
  # rubocop:enable Metrics/ClassLength
end
