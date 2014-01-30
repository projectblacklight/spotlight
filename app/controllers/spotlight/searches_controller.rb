class Spotlight::SearchesController < Spotlight::ApplicationController
  load_and_authorize_resource

  def create
    params_copy = params.dup
    @search.title = params_copy.delete(:search)[:title]
    @search.query_params = params_copy.reject { |k,v| blacklisted_search_session_params.include?(k.to_sym) or v.blank? }
    @search.save!

    redirect_to main_app.catalog_index_path, notice: "Search has been saved"
  end

  protected

  def blacklisted_search_session_params
    super + [:action, :controller]
  end
end
