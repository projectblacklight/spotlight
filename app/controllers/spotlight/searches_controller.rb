class Spotlight::SearchesController < Spotlight::ApplicationController
  load_resource :exhibit, class: "Spotlight::Exhibit"
  before_filter :authenticate_user!
  before_filter :only_curators!
  load_and_authorize_resource through: :exhibit
  before_filter :attach_breadcrumbs, only: [:index, :edit], unless: -> { request.format.json? }

  include Spotlight::Base

  def create
    params_copy = params.dup
    params_copy.delete(:exhibit_id)
    @search.title = params_copy.delete(:search)[:title]
    @search.query_params = params_copy.reject { |k,v| blacklisted_search_session_params.include?(k.to_sym) or v.blank? }
    @search.save!

    redirect_to :back, notice: t(:'helpers.submit.search.created', model: @search.class.model_name.human.downcase)
  end

  def index
    respond_to do |format|
      format.html
      format.json { render json: @searches.published.as_json(methods: [:count, :thumbnail_image_url]), root: false }
    end
  end

  def autocomplete
    (_, document_list) = get_search_results(autocomplete_params, blacklight_config.default_autocomplete_solr_params)

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
    redirect_to :back, notice: notice
  end

  def show
    redirect_to exhibit_browse_url(@search.exhibit, @search)
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
    e = @exhibit || (@search.exhibit if @search)
    add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: e.title), e
    add_breadcrumb t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(e)
    add_breadcrumb t(:'spotlight.curation.sidebar.browse'), exhibit_searches_path(e)
  end

  def batch_search_params
    params.require(:exhibit).permit("searches_attributes" => [:id, :on_landing_page, :weight])
  end

  def search_params
    params.require(:search).permit(:title, :long_description, masthead_attributes: featured_image_attributes, thumbnail_attributes: featured_image_attributes)
  end
  
  def featured_image_attributes
    [:display, :source, :image, :remote_image_url, :document_global_id, :image_crop_x, :image_crop_y, :image_crop_w, :image_crop_h]
  end

  def only_curators!
    authorize! :curate, @exhibit if @exhibit
  end

  def blacklisted_search_session_params
    [:commit, :counter, :total, :search_id, :page, :per_page, :authenticity_token, :utf8, :action, :controller]
  end
end
