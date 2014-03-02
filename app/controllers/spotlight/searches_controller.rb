class Spotlight::SearchesController < Spotlight::ApplicationController
  load_resource :exhibit, class: "Spotlight::Exhibit", only: [:index, :create, :update_all]
  before_filter :authenticate_user!
  before_filter :only_curators!
  load_and_authorize_resource through: :exhibit
  before_filter :attach_breadcrumbs, only: [:index, :edit]


  def create
    params_copy = params.dup
    params_copy.delete(:exhibit_id)
    @search.title = params_copy.delete(:search)[:title]
    @search.query_params = params_copy.reject { |k,v| blacklisted_search_session_params.include?(k.to_sym) or v.blank? }
    @search.save!

    redirect_to main_app.catalog_index_path, notice: "Search has been saved"
  end

  def index
  end

  def edit
    add_breadcrumb @search.title, edit_exhibit_search_path(@search.exhibit, @search)
    @exhibit = @search.exhibit
  end

  def update
    if @search.update params.require(:search).permit(:title, :short_description, :long_description, :featured_image)
      redirect_to exhibit_searches_path(@search.exhibit), notice: "Search has been saved"
    else
      render action: 'edit'
    end
  end

  def destroy
    @search.destroy
    redirect_to exhibit_searches_path(@search.exhibit), alert: "Search was deleted"
  end

  def update_all
    notice = if @exhibit.update search_params
      "Searches were successfully updated."
    else
      "There was an error updating the requested searches."
    end
    redirect_to :back, notice: notice
  end

  protected

  def attach_breadcrumbs
    e = @exhibit || (@search.exhibit if @search)
    add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: e.title), e
    add_breadcrumb t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(e)
    add_breadcrumb t(:'spotlight.curation.sidebar.browse'), exhibit_searches_path(e)
  end

  def search_params
    params.require(:exhibit).permit("searches_attributes" => [:id, :on_landing_page, :weight])
  end

  def only_curators!
    authorize! :curate, @exhibit if @exhibit
  end

  def blacklisted_search_session_params
    [:commit, :counter, :total, :search_id, :page, :per_page, :authenticity_token, :utf8, :action, :controller]
  end
end
