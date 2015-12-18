module Spotlight
  ##
  # Proxy update requests to Solr and inject spotlight's exhibit
  # specific fields.
  #
  # This is an example of how you could integrate external indexing
  # workflows with exhibit-specific content
  class SolrController < Spotlight::ApplicationController
    before_action :authenticate_user!
    before_action :validate_writable_index!

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

    private

    def validate_writable_index!
      return if Spotlight::Engine.config.writable_index

      render text: 'Spotlight is unable to write to solr', status: 409
    end
  end
end
