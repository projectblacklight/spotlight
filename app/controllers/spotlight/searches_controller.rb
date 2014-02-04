class Spotlight::SearchesController < Spotlight::ApplicationController
  load_resource :exhibit, class: "Spotlight::Exhibit", only: [:index, :create]
  before_filter :authenticate_user!
  before_filter :only_curators!
  load_and_authorize_resource through: :exhibit, shallow: true

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
    @exhibit = @search.exhibit
  end

  def update
    if @search.update params.require(:search).permit(:title, :short_description, :long_description, :featured_image)
      redirect_to exhibit_searches_path(@search.exhibit), notice: "Search has been saved"
    else
      render :edit
    end

  end

  protected

  def only_curators!
    authorize! :curate, @exhibit if @exhibit
  end

  def blacklisted_search_session_params
    [:commit, :counter, :total, :search_id, :page, :per_page, :authenticity_token, :utf8, :action, :controller]
  end
end
