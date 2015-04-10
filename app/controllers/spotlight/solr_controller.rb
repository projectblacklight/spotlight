module Spotlight
  ##
  # Proxy update requests to Solr and inject spotlight's exhibit
  # specific fields.
  #
  # This is an example of how you could integrate external indexing
  # workflows with exhibit-specific content
  class SolrController < Spotlight::ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit

    def update
      authorize! :update_solr, @exhibit

      req = ActiveSupport::JSON.decode(request.body.read)

      docs = Array.wrap(req).map do |r|
        blacklight_config.document_model.new(r).to_solr.merge(@exhibit.solr_data).merge(r)
      end

      blacklight_solr.update docs

      render nothing: true
    end
  end
end
