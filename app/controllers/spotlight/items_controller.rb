module Spotlight
  class ItemsController < Spotlight::ApplicationController
    before_filter :authenticate_user!, except: [:show]
    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit

    include Blacklight::Catalog

    def edit
      _, @document = get_solr_response_for_doc_id    
      authorize! :edit, @document
    end

  end
end
