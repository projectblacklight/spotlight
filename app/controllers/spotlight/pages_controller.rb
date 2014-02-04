module Spotlight
  class PagesController < ApplicationController
    before_filter :authenticate_user!, except: [:show]

    load_resource :exhibit, class: Spotlight::Exhibit, only: [:index, :new, :create]
    load_and_authorize_resource only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource through: :exhibit, only: [:index, :new, :create]

    before_filter :cast_page_instance_variable

    include Blacklight::Base
    include Blacklight::Catalog::SearchContext

    copy_blacklight_config_from(CatalogController)

    helper_method :get_search_results, :get_solr_response_for_doc_id, :page_model

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

      if @page.save
        redirect_to [@exhibit, @page], notice: 'Page was successfully created.'
      else
        render action: 'new'
      end
    end

    # PATCH/PUT /pages/1
    def update
      if @page.update(page_params)
        redirect_to [@page.exhibit, @page], notice: 'Page was successfully updated.'
      else
        render action: 'edit'
      end
    end

    # DELETE /pages/1
    def destroy
      @page.destroy
      redirect_to [@page.exhibit, @page], notice: 'Page was successfully destroyed.'
    end

    private
      # We don't have a generic page model since Spotlight::Page is now a concern.
      def page_model
        ""
      end
      # Only allow a trusted parameter "white list" through.
      def page_params
        params.require(page_model.to_sym).permit(:title, :content)
      end
  end
end
