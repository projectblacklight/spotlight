module Spotlight
  class PagesController < Spotlight::ApplicationController
    before_filter :authenticate_user!, except: [:show]

    load_resource :exhibit, class: Spotlight::Exhibit, only: [:index, :new, :create, :update_all]
    load_and_authorize_resource only: [:show, :edit, :update, :destroy, :update_all], instance_name: 'page'
    load_and_authorize_resource through: :exhibit, only: [:index, :new, :create], instance_name: 'page'

    before_filter :attach_breadcrumbs

    include Blacklight::Base
    include Blacklight::Catalog::SearchContext

    copy_blacklight_config_from(CatalogController)

    helper_method :get_search_results, :get_solr_response_for_doc_id, :get_solr_response_for_field_values, :page_model, :page_collection_name

    # GET /exhibits/1/pages
    def index
    end

    # GET /pages/1
    def show
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
        redirect_to [@page.exhibit, page_collection_name], notice: 'Page was successfully created.'
      else
        render action: 'new'
      end
    end

    # PATCH/PUT /pages/1
    def update
      if @page.update(page_params.merge(last_edited_by: current_user))
        redirect_to [@page.exhibit, page_collection_name], notice: 'Page was successfully updated.'
      else
        render action: 'edit'
      end
    end

    # DELETE /pages/1
    def destroy
      @page.destroy
      redirect_to [@page.exhibit, @page], notice: 'Page was successfully destroyed.'
    end

    def update_all
      notice = if @exhibit.update update_all_page_params
        "#{human_name} were successfully updated."
      else
        "There was an error updating the requested pages."
      end
      redirect_to :back, notice: notice
    end

    protected

    def update_all_page_params
      params.require(:exhibit).permit("#{page_collection_name}_attributes" => [:id, :published, :title, :weight, :display_sidebar, :parent_page_id ])
    end

    def human_name
      @human_name ||= page_collection_name.humanize
    end

    def page_model
      @page_model ||= controller_name.singularize
    end

    alias page_collection_name controller_name 

    def attach_breadcrumbs
      load_exhibit
      add_breadcrumb @exhibit.title, @exhibit
    end

    def load_exhibit
      @exhibit ||= @page.exhibit
    end

    private

      # Only allow a trusted parameter "white list" through.
      def page_params
        params.require(page_model).permit(:title, :content)
      end
  end
end
