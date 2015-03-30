class Spotlight::SolrController < Spotlight::ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :exhibit, class: Spotlight::Exhibit

  def update
    authorize! :update_solr, @exhibit

    req = ActiveSupport::JSON.decode(request.body.read)

    docs = Array.wrap(req).map do |r|
      SolrDocument.new(r).to_solr.merge(@exhibit.solr_data).merge(r)
    end

    blacklight_solr.update docs

    render nothing: true
  end

end