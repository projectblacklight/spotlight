# frozen_string_literal: true

module Spotlight
  ##
  # CRUD actions for curating browse categories (see
  # {Spotlight::BrowseController} for the end-user read and index actions)
  class SearchesController < Spotlight::ApplicationController
    load_and_authorize_resource :exhibit, class: 'Spotlight::Exhibit', parent_action: :curate
    before_action :authenticate_user!
    before_action :create_or_load_resource, only: [:create]
    load_and_authorize_resource through: :exhibit
    before_action :attach_breadcrumbs, only: %i[index edit], unless: -> { request.format.json? }

    include Spotlight::Base
    include Spotlight::SearchHelper

    def index
      @groups = @exhibit.groups
      respond_to do |format|
        format.html
        format.json do
          render json: @searches.as_json(methods: %i[full_title count thumbnail_image_url]), root: false
        end
      end
    end

    def show
      redirect_to exhibit_browse_url(@search.exhibit, @search)
    end

    def edit
      @groups = @exhibit.groups
      add_breadcrumb(@search.full_title, edit_exhibit_search_path(@search.exhibit, @search))
      @exhibit = @search.exhibit
    end

    def create
      @search.assign_attributes(search_params.except((:title unless @search.new_record?)))
      @search.query_params = query_params

      if @search.save
        redirect_back fallback_location: fallback_url,
                      notice: t(:'helpers.submit.search.created', model: @search.class.model_name.human.downcase)
      else
        redirect_back fallback_location: fallback_url, alert: @search.errors.full_messages.join('<br>'.html_safe)
      end
    end

    def autocomplete
      search_params = autocomplete_params.merge(search_field: Spotlight::Engine.config.autocomplete_search_field)
      (response, _document_list) = search_service.search_results do |builder|
        builder.with(search_params)
      end

      respond_to do |format|
        format.json do
          render json: { docs: autocomplete_json_response(response.documents) }
        end
      end
    end

    def update
      if @search.update search_params
        redirect_to exhibit_searches_path(@search.exhibit), notice: t(:'helpers.submit.search.updated', model: @search.class.model_name.human.downcase)
      else
        render action: 'edit'
      end
    end

    def destroy
      @search.destroy
      redirect_to exhibit_searches_path(@search.exhibit), alert: t(:'helpers.submit.search.destroyed', model: @search.class.model_name.human.downcase)
    end

    def update_all
      notice = if @exhibit.update batch_search_params
                 t(:'helpers.submit.search.batch_updated', model: Spotlight::Search.model_name.human.pluralize)
               else
                 t(:'helpers.submit.search.batch_error', model: Spotlight::Search.model_name.human.pluralize.downcase)
               end
      redirect_back fallback_location: fallback_url, notice:
    end

    protected

    def autocomplete_params
      ##
      # Ideally, we would be able to search within results for all queries, but in practice
      # searching within saved searches with a `q` parameter is.. hard.

      query_params = @search.query_params.with_indifferent_access
      query_params.merge(q: params[:q])
    end

    def attach_breadcrumbs
      e = @exhibit || @search&.exhibit
      add_breadcrumb(t(:'spotlight.exhibits.breadcrumb', title: e.title), e)
      add_breadcrumb(t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(e))
      add_breadcrumb(t(:'spotlight.curation.sidebar.browse'), exhibit_searches_path(e))
    end

    def batch_search_params
      params.require(:exhibit).permit('searches_attributes' => %i[id published weight])
    end

    def search_params
      params.require(:search).permit(
        :title,
        :subtitle,
        :long_description,
        :search_box,
        :default_index_view_type,
        group_ids: [],
        masthead_attributes: featured_image_params,
        thumbnail_attributes: featured_image_params
      )
    end

    def query_params
      params.to_unsafe_h.with_indifferent_access.except(:exhibit_id, :search, *excluded_search_session_params).reject { |_k, v| v.blank? }
    end

    def excluded_search_session_params
      blacklisted_search_session_params
    end

    # @deprecated
    def blacklisted_search_session_params
      %i[id commit counter total search_id page per_page authenticity_token utf8 action controller]
    end

    def fallback_url
      spotlight.exhibit_searches_path(current_exhibit)
    end

    def create_or_load_resource
      @search = current_exhibit.searches.find(params[:id]) if params[:id].present?
    end
  end
end
