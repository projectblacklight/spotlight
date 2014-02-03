class Spotlight::Search < ActiveRecord::Base
  self.table_name = 'spotlight_searches'
  belongs_to :exhibit
  serialize :query_params, Hash

  include Blacklight::SolrHelper

  def count
    query_solr(query_params, rows: 0, facet: false)['response']['numFound']
  end

  private

  def blacklight_config
    CatalogController.blacklight_config
  end

end
