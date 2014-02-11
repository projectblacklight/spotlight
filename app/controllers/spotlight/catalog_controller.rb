class Spotlight::CatalogController < Spotlight::ApplicationController
  include Blacklight::Catalog
  load_resource :exhibit, class: Spotlight::Exhibit
  before_filter :authenticate_user!
  before_filter :check_authorization

  copy_blacklight_config_from ::CatalogController

  def admin
    self.blacklight_config.view.reject! { |k,v| true }
    self.blacklight_config.view.admin_table.partials = [:index_compact]

    (@response, @document_list) = get_search_results
    @filters = params[:f] || []
      
    respond_to do |format|
      format.html
    end
  end

  def _prefixes
    @_prefixes ||= super + ['catalog']
  end

  protected

  def check_authorization
    authorize! :curate, @exhibit
  end
end
