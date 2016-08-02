module Spotlight
  ##
  # CRUD actions for curating browse categories (see
  # {Spotlight::BrowseController} for the end-user read and index actions)
  # rubocop:disable Metrics/ClassLength
  class SearchesController < Spotlight::ApplicationController
    load_resource :exhibit, class: 'Spotlight::Exhibit'
    before_action :authenticate_user!
    before_action :only_curators!
    load_and_authorize_resource through: :exhibit
    before_action :attach_breadcrumbs, only: [:index, :edit], unless: -> { request.format.json? }

    include Spotlight::Base

    def create
      @search.attributes = search_params
      @search.query_params = query_params

      if @search.save
        redirect_back fallback_location: fallback_url,
                      notice: t(:'helpers.submit.search.created', model: @search.class.model_name.human.downcase)
      else
        redirect_back fallback_location: fallback_url, alert: @search.errors.full_messages.join('<br>'.html_safe)
      end
    end

    def index
      respond_to do |format|
        format.html
        format.json { render json: @searches.published.as_json(methods: [:count, :thumbnail_image_url]), root: false }
      end
    end

    def autocomplete
      search_params = autocomplete_params.merge(search_field: Spotlight::Engine.config.autocomplete_search_field)
      (_, document_list) = search_results(search_params)

      respond_to do |format|
        format.json do
          render json: { docs: autocomplete_json_response(document_list) }
        end
      end
    end

    def edit
      add_breadcrumb @search.title, edit_exhibit_search_path(@search.exhibit, @search)
      @exhibit = @search.exhibit
    end

    def update
      if @search.update search_params
        # Update masthead attributes, only after we have saved the masthead_id
        update_masthead
        # Update thumbnail attributes, only after we have saved the thumbnail_id
        update_thumbnail

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
      redirect_back fallback_location: fallback_url, notice: notice
    end

    def show
      redirect_to exhibit_browse_url(@search.exhibit, @search)
    end

    protected

    def update_masthead
      return unless @search.masthead
      @search.masthead.update(params.require(:search).require(:masthead_attributes).permit(featured_image_params))
    end

    def update_thumbnail
      return unless @search.thumbnail
      @search.thumbnail.update(params.require(:search).require(:thumbnail_attributes).permit(featured_image_params))
    end

    def autocomplete_params
      ##
      # Ideally, we would be able to search within results for all queries, but in practice
      # searching within saved searches with a `q` parameter is.. hard.

      query_params = @search.query_params.with_indifferent_access
      query_params.merge(q: params[:q])
    end

    def attach_breadcrumbs
      e = @exhibit || (@search.exhibit if @search)
      add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: e.title), e
      add_breadcrumb t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(e)
      add_breadcrumb t(:'spotlight.curation.sidebar.browse'), exhibit_searches_path(e)
    end

    def batch_search_params
      params.require(:exhibit).permit('searches_attributes' => [:id, :published, :weight])
    end

    def search_params
      params.require(:search).permit(
        :title,
        :long_description,
        :default_index_view_type,
        :masthead_id,
        :thumbnail_id
      )
    end

    def query_params
      params.to_unsafe_h.with_indifferent_access.except(:exhibit_id, :search, *blacklisted_search_session_params).reject { |_k, v| v.blank? }
    end

    def featured_image_params
      [
        :iiif_url,
        :display,
        :source,
        :image,
        :remote_image_url,
        :document_global_id,
        # :image_crop_x, :image_crop_y, :image_crop_w, :image_crop_h
      ]
    end

    def only_curators!
      authorize! :curate, @exhibit if @exhibit
    end

    def blacklisted_search_session_params
      [:commit, :counter, :total, :search_id, :page, :per_page, :authenticity_token, :utf8, :action, :controller]
    end

    def fallback_url
      spotlight.exhibit_searches_path(current_exhibit)
    end
  end
  # rubocop:enable Metrics/ClassLength
end
