module Spotlight
  ##
  # Proxy update requests to Solr and inject spotlight's exhibit
  # specific fields.
  #
  # This is an example of how you could integrate external indexing
  # workflows with exhibit-specific content
  class SolrController < Spotlight::ApplicationController
    include Blacklight::SearchHelper

    before_action :authenticate_user!
    before_action :validate_writable_index!

    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
    delegate :blacklight_config, to: :current_exhibit

    def update
      authorize! :update_solr, @exhibit

      data = solr_documents

      repository.connection.update params: { commitWithin: 500 }, data: data.to_json, headers: { 'Content-Type' => 'application/json' } unless data.empty?

      if params[:resources_json_upload]
        redirect_back fallback_location: exhibit_resources_path(@exhibit)
      else
        head :ok
      end
    end

    private

    def solr_documents
      req = ActiveSupport::JSON.decode(json_content)

      Array.wrap(req).map do |r|
        blacklight_config.document_model.new(r).to_solr.merge(@exhibit.solr_data).merge(r)
      end
    end

    def json_content
      if params[:resources_json_upload]
        params[:resources_json_upload][:json].read
      else
        request.body.read
      end
    end

    def validate_writable_index!
      return if Spotlight::Engine.config.writable_index

      render plain: 'Spotlight is unable to write to solr', status: 409
    end
  end
end
