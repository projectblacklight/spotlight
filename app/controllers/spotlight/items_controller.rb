module Spotlight
  class ItemsController < Spotlight::ApplicationController
    before_filter :authenticate_user!, except: [:show]
    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
    load_and_authorize_resource class: ::SolrDocument, only: [:edit, :update]
    include Blacklight::Catalog
    copy_blacklight_config_from ::CatalogController

    def edit
    end

    def update
      @item.tag_list = params[:solr_document][:tag_list]
      @item.save # TODO need to index tags too
      @document = @item # show templates expect @document
      render :show
    end

    protected


  end
end
