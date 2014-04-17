module Spotlight
  class PagesController < Spotlight::ApplicationController
    before_filter :authenticate_user!, except: [:show]
    load_resource :exhibit, class: Spotlight::Exhibit

    include Spotlight::Base
    include Blacklight::Catalog::SearchContext
    include Spotlight::Catalog::AccessControlsEnforcement

    helper_method :get_search_results, :get_solr_response_for_doc_id, :get_solr_response_for_field_values, :page_collection_name

    # GET /exhibits/1/pages
    def index
      # set up a model the inline "add a new page" form
      @page = CanCan::ControllerResource.new(self).send(:build_resource)
    end

    # GET /pages/1
    def show
      fresh_when(@page)
    end

    # GET /exhibits/1/pages/new
    def new
    end

    # GET /pages/1/edit
    def edit
    end

    # POST /exhibits/1/pages
    def create
      @page.attributes = page_params
      @page.last_edited_by = @page.created_by = current_user

      if @page.save
        redirect_to [@page.exhibit, page_collection_name], notice: t(:'helpers.submit.page.created', model: @page.class.model_name.human.downcase)
      else
        render action: 'new'
      end
    end

    # PATCH/PUT /pages/1
    def update
      if @page.update(page_params.merge(last_edited_by: current_user))
        redirect_to [@page.exhibit, @page], notice: t(:'helpers.submit.page.updated', model: @page.class.model_name.human.downcase)
      else
        render action: 'edit'
      end
    end

    # DELETE /pages/1
    def destroy
      @page.destroy
      redirect_to [@page.exhibit, page_collection_name], notice: t(:'helpers.submit.page.destroyed', model: @page.class.model_name.human.downcase)
    end

    def update_all
      notice = if @exhibit.update update_all_page_params
        t(:'helpers.submit.page.batch_updated', model: human_name)
      else
        t(:'helpers.submit.page.batch_error', model: human_name)
      end
      redirect_to :back, notice: notice
    end

    def _prefixes
      @_prefixes ||= super + ['catalog']
    end

    protected

    ##
    # Browsing an exhibit should start a new search session
    def start_new_search_session?
      params[:action] == 'show'
    end

    def page_attributes
      [:id, :published, :title, :weight, :display_sidebar, :parent_page_id ]
    end

    def allowed_page_params
      [:title, :content]
    end

    def human_name
      @human_name ||= page_collection_name.humanize
    end

    alias page_collection_name controller_name 

    def attach_breadcrumbs
      if view_context.current_page? "/"
        add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: current_exhibit.title), main_app.root_path
      else
        add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: current_exhibit.title), spotlight.exhibit_root_path(current_exhibit)
      end
    end

    private
      # Only allow a trusted parameter "white list" through.
      def page_params
        params.require(controller_name.singularize).permit(allowed_page_params)
      end
  end
end
