# frozen_string_literal: true

module Spotlight
  ##
  # Index and read actions for browse (see {Spotlight::SearchesController}
  # for the curator's create-update-delete actions)
  class BrowseController < Spotlight::ApplicationController
    load_and_authorize_resource :exhibit, class: 'Spotlight::Exhibit'
    include Spotlight::Catalog
    include Blacklight::Facet

    load_and_authorize_resource :group, through: :exhibit
    load_and_authorize_resource :search, through: %i[group exhibit], parent: false
    before_action :attach_breadcrumbs
    before_action :attach_search_breadcrumb, only: :show
    record_search_parameters only: :show

    helper_method :should_render_spotlight_search_bar?, :presenter

    before_action :swap_actions_configuration, only: :show

    before_action do
      blacklight_config.track_search_session = false
      blacklight_config.view.gallery.classes = 'row-cols-2 row-cols-md-4'
    end

    def index
      @groups = @exhibit.groups.published
      @searches = @searches.published
    end

    # rubocop:disable Metrics/MethodLength
    def show
      @response, @document_list = search_service.search_results do |builder|
        builder.with(search_query)
      end

      respond_to do |format|
        format.html
        format.rss  { render layout: false }
        format.atom { render layout: false }
        format.json do
          @presenter = Blacklight::JsonPresenter.new(@response, blacklight_config)
          render template: 'catalog/index'
        end
        additional_response_formats(format)
        document_export_formats(format)
      end
    end
    # rubocop:enable Metrics/MethodLength

    protected

    ##
    # Render additional response formats for the index action, as provided by the
    # blacklight configuration
    # @param [Hash] format
    # @note Make sure your format has a well known mime-type or is registered in config/initializers/mime_types.rb
    # @example
    #   config.index.respond_to.txt = Proc.new { render plain: "A list of docs." }
    # rubocop:disable Metrics/MethodLength
    def additional_response_formats(format)
      blacklight_config.index.respond_to.each do |key, config|
        format.send key do
          case config
          when false
            raise ActionController::RoutingError, 'Not Found'
          when Hash
            render config
          when Proc
            instance_exec(&config)
          when Symbol, String
            send config
          else
            render({})
          end
        end
      end
    end
    # rubocop:enable Metrics/MethodLength

    ##
    # Render the document export formats for a response
    # First, try to render an appropriate template (e.g. index.endnote.erb)
    # If that fails, just concatenate the document export responses with a newline.
    def render_document_export_format(format_name)
      render 'catalog/index'
    rescue ActionView::MissingTemplate
      render plain: @response.documents.map { |x| x.export_as(format_name) if x.exports_as? format_name }.compact.join("\n"), layout: false
    end

    ##
    # Try to render a response from the document export formats available
    def document_export_formats(format)
      format.any do
        format_name = params.fetch(:format, '').to_sym
        raise ActionController::UnknownFormat unless @response.export_formats.include? format_name

        render_document_export_format format_name
      end
    end

    def swap_actions_configuration
      blacklight_config.index.document_actions = blacklight_config.browse.document_actions
      blacklight_config.action_mapping.show.top_level_config = :index if blacklight_config.key?(:action_mapping)
    end

    def search_query
      @search.query_params['q'] = [@search.query_params['q'], params[:browse_q]].join(' ')
      @search.merge_params_for_search(params, blacklight_config)
    end

    ##
    # Browsing an exhibit should start a new search session
    def start_new_search_session?
      params[:action] == 'show'
    end

    # WARNING: Blacklight::Catalog::SearchContext sets @searches in history_session in a before_filter
    # See https://github.com/projectblacklight/blacklight/pull/780
    def history_session
      # nop
    end

    def attach_breadcrumbs
      add_breadcrumb t(:'spotlight.curation.nav.home', title: @exhibit.title), @exhibit
      add_breadcrumb(@exhibit.main_navigations.browse.label_or_default, exhibit_browse_index_path(@exhibit))
      add_breadcrumb(@group.title, exhibit_browse_groups_path(@exhibit, @group)) if @group.present?
    end

    def attach_search_breadcrumb
      add_breadcrumb @search.full_title, (@group.present? ? exhibit_browse_group_path(@exhibit, @group, @search) : exhibit_browse_path(@exhibit, @search))
    end

    def _prefixes
      @_prefixes ||= super + ['catalog']
    end

    def current_masthead
      if resource_masthead?
        @search.masthead
      else
        super
      end
    end

    def resource_masthead?
      @search&.masthead && @search.masthead.display?
    end

    # This is overidden for the browse controller context from where it is defined in a helper
    # (which just checks if the current exhibit is searchable) in order to also prevent showing the search bar
    # if the current browse category is configured to display its masthead
    def should_render_spotlight_search_bar?
      current_exhibit&.searchable? && !resource_masthead?
    end

    def document_index_view_type
      return super if params[:view].present?

      if @search && @search.default_index_view_type.present?
        blacklight_config.view[@search.default_index_view_type].key
      else
        default_document_index_view_type
      end
    end

    helper_method :document_index_view_type

    def default_document_index_view_type
      if view_available? default_browse_index_view_type
        default_browse_index_view_type
      else
        super
      end
    end

    def view_available?(view)
      blacklight_config.view.key?(view) && blacklight_configuration_context.evaluate_if_unless_configuration(blacklight_config.view)
    end

    def default_browse_index_view_type
      Spotlight::Engine.config.default_browse_index_view_type
    end

    def presenter(document)
      view_context.index_presenter(document)
    end

    def render_save_this_search?
      false
    end

    def render_curator_actions?
      false
    end
  end
end
