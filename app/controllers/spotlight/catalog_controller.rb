class Spotlight::CatalogController < Spotlight::ApplicationController
  include Blacklight::Catalog
  include Spotlight::Catalog
  load_resource :exhibit, class: Spotlight::Exhibit
  before_filter :authenticate_user!, only: [:admin, :edit]
  before_filter :check_authorization, only: [:admin, :edit]
  load_and_authorize_resource instance_name: :document, class: ::SolrDocument, only: [:edit]

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

  def update
    if params[:solr_document]
      @document = ::SolrDocument.find params[:id] 
      authenticate_user!
      authorize! :update, @document
      @document.update(current_exhibit, solr_document_params)
      @document.save # TODO need to index tags too
      redirect_to exhibit_catalog_path(current_exhibit, @document)
    else
      super
    end
  end

  def edit
    blacklight_config.view.edit.partials = blacklight_config.view_config(:show).partials.dup
    blacklight_config.view.edit.partials.delete "spotlight/catalog/tags"
    blacklight_config.view.edit.partials.insert(2, :edit)
  end

  def _prefixes
    @_prefixes ||= super + ['catalog']
  end

  protected

  ##
  # Admin catalog controller should not create a new search
  # session in the blacklight context
  def start_new_search_session?
    super || params[:action] == 'admin'
  end

  def solr_document_params
    params.require(:solr_document).permit(:exhibit_tag_list, sidecar: { data: [custom_field_params] })
  end

  def custom_field_params
    current_exhibit.custom_fields.pluck(:field)
  end

  def check_authorization
    authorize! :curate, @exhibit
  end
end
