class Spotlight::CatalogController < ::CatalogController
  include Spotlight::Concerns::ApplicationController
  load_and_authorize_resource :exhibit, class: Spotlight::Exhibit, prepend: true
  include Spotlight::Catalog
  before_filter :authenticate_user!, only: [:admin, :edit, :make_public, :make_private]
  before_filter :check_authorization, only: [:admin, :edit, :make_public, :make_private]
  before_filter :redirect_to_exhibit_home_without_search_params, only: :index
  before_filter :add_breadcrumb_with_search_params, only: :index

  before_filter :attach_breadcrumbs
  

  def new
    add_breadcrumb t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(@exhibit)
    add_breadcrumb t(:'spotlight.curation.sidebar.items'), admin_exhibit_catalog_index_path(@exhibit)
    add_breadcrumb t(:'spotlight.catalog.new.header'), new_exhibit_catalog_path(@exhibit)
    @resource = @exhibit.resources.build
  end

  def show
    blacklight_config.show.partials.unshift "curation_mode_toggle"
    super

    if @document.private? current_exhibit
      authenticate_user!
      authorize! :curate, current_exhibit
    end

    if current_browse_category
      add_breadcrumb current_browse_category.exhibit.main_navigations.browse.label_or_default, exhibit_browse_index_path(current_browse_category.exhibit)
      add_breadcrumb current_browse_category.title, exhibit_browse_path(current_browse_category.exhibit, current_browse_category)
    elsif current_page_context
      add_breadcrumb current_page_context.title, [current_page_context.exhibit, current_page_context] if current_page_context.title.present? and !current_page_context.is_a?(Spotlight::HomePage)
    else
      add_breadcrumb t(:'spotlight.catalog.breadcrumb.index'), search_action_url(current_search_session[:query_params]) if current_search_session
    end
    add_breadcrumb Array(@document[blacklight_config.view_config(:show).title_field]).join(', '), exhibit_catalog_path(@exhibit, @document)
  end

  # "id_ng" and "full_title_ng" should be defined in the Solr core's schema.xml.
  # It's expected that these fields will be set up to have  EdgeNGram filter
  # setup within their index analyzer. This will ensure that this method returns
  # results when a partial match is passed in the "q" parameter.
  def autocomplete
    (_, @document_list) = get_search_results(params.merge(search_field: Spotlight::Engine.config.autocomplete_search_field), facet: false, "facet.field" => [], fq: ["-#{Spotlight::SolrDocument.visibility_field(current_exhibit)}:false"])

    respond_to do |format|
      format.json do
        render json: { docs: autocomplete_json_response(@document_list) }
      end
    end
  end

  def admin
    self.blacklight_config.view.select! { |k,v| k == :admin_table }
    self.blacklight_config.view.admin_table.partials = [:index_compact]
    self.blacklight_config.view.admin_table.document_actions = []

    unless self.blacklight_config.sort_fields.has_key? :timestamp
      self.blacklight_config.add_sort_field :timestamp, sort: "#{blacklight_config.index.timestamp_field} desc"
    end

    add_breadcrumb t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(@exhibit)
    add_breadcrumb t(:'spotlight.curation.sidebar.items'), admin_exhibit_catalog_index_path(@exhibit)
    (@response, @document_list) = get_search_results
    @filters = params[:f] || []
      
    respond_to do |format|
      format.html
    end
  end

  def update
    @response, @document = fetch params[:id]
    @document.update(current_exhibit, solr_document_params)
    @document.save
    repository.connection.commit rescue nil
    redirect_to exhibit_catalog_path(current_exhibit, @document)
  end

  def edit
    @response, @document = fetch params[:id]
    blacklight_config.view.edit.partials = blacklight_config.view_config(:show).partials.dup
    blacklight_config.view.edit.partials.delete "spotlight/catalog/tags"
    blacklight_config.view.edit.partials.insert(2, :edit)
  end

  def make_private
    @response, @document = fetch params[:catalog_id]
    @document.make_private!(current_exhibit)
    @document.save

    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render json: true }
    end
  end

  def make_public
    @response, @document = fetch params[:catalog_id]
    @document.make_public!(current_exhibit)
    @document.save

    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render json: true }
    end
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
    add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), exhibit_root_path(@exhibit, q: '')
  end

  ## 
  # Override Blacklight's #setup_next_and_previous_documents to handle
  # browse categories too
  def setup_next_and_previous_documents
    if current_browse_category
      index = search_session['counter'].to_i - 1
      response, documents = get_previous_and_next_documents_for_search index, current_browse_category.query_params.with_indifferent_access
      search_session['total'] = response.total
      @search_context_response = response
      @previous_document = documents.first
      @next_document = documents.last
    elsif current_page_context
      # TODO: figure out how to construct previous/next documents 
    else
      super
    end
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
    params.require(:solr_document).permit(:exhibit_tag_list, uploaded_resource: [:url], sidecar: [:public, data: [editable_solr_document_params] ])
  end

  def editable_solr_document_params
    custom_field_params + uploaded_resource_params
  end

  def uploaded_resource_params
    if @document.uploaded_resource?
      [{configured_fields: Spotlight::Resources::Upload.fields(current_exhibit).collect(&:field_name)}]
    else
      []
    end
  end

  def custom_field_params
    current_exhibit.custom_fields.pluck(:field)
  end

  def check_authorization
    authorize! :curate, @exhibit
  end

  def current_browse_category
    @current_browse_category ||= if current_search_session and current_search_session.query_params["action"] == "show" and current_search_session.query_params["controller"] == "spotlight/browse"
      current_exhibit.searches.accessible_by(current_ability).find(current_search_session.query_params["id"]) if current_search_session.query_params["id"]
    end
  end

  def redirect_to_exhibit_home_without_search_params
    unless has_search_parameters?
      redirect_to spotlight.exhibit_root_path(@exhibit)
    end
  end

  def add_breadcrumb_with_search_params
    if has_search_parameters?
      add_breadcrumb t(:'spotlight.catalog.breadcrumb.index'), request.fullpath
    end
  end

  def current_page_context
    @current_page_context ||= if current_search_session and current_search_session.query_params["action"] == "show" and current_search_session.query_params["controller"].ends_with? "_pages"
      if current_search_session.query_params["controller"] == "spotlight/home_pages"
        current_exhibit.home_page if can? :read, current_exhibit.home_page
      else
        current_exhibit.pages.accessible_by(current_ability).find(current_search_session.query_params["id"]) if current_search_session.query_params["id"]
      end
    end
  end
end
