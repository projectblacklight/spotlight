class Spotlight::Search < ActiveRecord::Base

  extend FriendlyId
  friendly_id :title, use: [:slugged,:scoped,:finders,:history], scope: :exhibit

  self.table_name = 'spotlight_searches'
  belongs_to :exhibit
  serialize :query_params, Hash
  default_scope { order("weight ASC") }
  scope :published, -> { where(on_landing_page: true) }

  before_create do
    self.featured_image ||= default_featured_image
  end

  include Blacklight::SolrHelper

  def count
    query_solr(query_params, rows: 0, facet: false)['response']['numFound']
  end

  def images
    response = query_solr(query_params,
      rows: 1000,
      fl: [blacklight_config.index.title_field, blacklight_config.index.thumbnail_field],
      facet: false)

    Blacklight::SolrResponse.new(response, {}).docs.map do |result|
      doc = ::SolrDocument.new(result)

      [
        doc.first(blacklight_config.index.title_field),
        doc.first(blacklight_config.index.thumbnail_field)
      ]
    end
  end

  def default_featured_image
    images.first.last
  end

  private
  def should_generate_new_friendly_id?
    title_changed?
  end

  def blacklight_config
    exhibit.blacklight_config
  end

end
