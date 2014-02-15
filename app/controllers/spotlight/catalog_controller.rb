class Spotlight::CatalogController < Spotlight::ApplicationController
  include Blacklight::Catalog
  include Spotlight::Catalog
  load_resource :exhibit, class: Spotlight::Exhibit
  before_filter :authenticate_user!, only: [:admin, :edit]
  before_filter :check_authorization, only: [:admin, :edit]
  load_and_authorize_resource instance_name: :document, class: ::SolrDocument, only: [:edit]

  before_filter :attach_breadcrumbs

  copy_blacklight_config_from ::CatalogController

  def index
    super

    add_breadcrumb t(:'spotlight.catalog.breadcrumb.index'), request.fullpath if has_search_parameters?
  end

  def show
    super
    add_breadcrumb Array(@document[blacklight_config.view_config(:show).title_field]).join(', '), exhibit_catalog_path(@exhibit, @document)
  end

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

  protected

  # TODO move this out of app/helpers/blacklight/catalog_helper_behavior.rb and into blacklight/catalog.rb
  def has_search_parameters?
    !params[:q].blank? or !params[:f].blank? or !params[:search_field].blank?
  end

  def attach_breadcrumbs
    # The "q: ''" is necessary so that the breadcrumb builder recognizes that a path like this:
    # /exhibits/1?f%5Bgenre_sim%5D%5B%5D=map&q= is not the same as /exhibits/1
    # Otherwise the exhibit breadcrumb won't be a link.
    # see http://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-current_page-3F
    add_breadcrumb @exhibit.title, exhibit_path(@exhibit, q: '')
  end

  def _prefixes
    @_prefixes ||= super + ['catalog']
  end

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
