class Spotlight::CatalogController < Spotlight::ApplicationController
  include Blacklight::Catalog
  load_resource :exhibit, class: Spotlight::Exhibit
  before_filter :authenticate_user!
  before_filter :check_authorization
  load_and_authorize_resource instance_name: :document, class: ::SolrDocument, only: [:edit, :update]

  copy_blacklight_config_from ::CatalogController

  def index
    self.blacklight_config.view.reject! { |k,v| true }
    self.blacklight_config.view.admin_table.partials = [:index_compact]

    (@response, @document_list) = get_search_results
    @filters = params[:f] || []
      
    respond_to do |format|
      format.html
    end
  end

  def edit
    blacklight_config.view.edit.partials = blacklight_config.view_config(:show).partials.dup

    blacklight_config.view.edit.partials.insert(1, :edit_tags)
  end

  def update
    @document.update(solr_document_params)
    @document.save # TODO need to index tags too
    render :show
  end

  def _prefixes
    @_prefixes ||= super + ['catalog']
  end

  protected

  def solr_document_params
    params.require(:solr_document).permit(:tag_list)
  end

  def check_authorization
    authorize! :curate, @exhibit
  end
end
