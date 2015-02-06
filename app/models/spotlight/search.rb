class Spotlight::Search < ActiveRecord::Base

  extend FriendlyId
  friendly_id :title, use: [:slugged,:scoped,:finders,:history], scope: :exhibit

  self.table_name = 'spotlight_searches'
  belongs_to :exhibit
  serialize :query_params, Hash
  default_scope { order("weight ASC") }
  scope :published, -> { where(on_landing_page: true) }
  validates :title, presence: true

  before_create do
    self.featured_item_id ||= default_featured_item_id
  end

  include Blacklight::SolrHelper
  include Spotlight::Catalog::AccessControlsEnforcement

  def featured_item
    if self.featured_item_id.present?
      @featured_item ||= get_solr_response_for_doc_id(self.featured_item_id).last
    end
  end

  def featured_image
    if featured_item
      Array[featured_item[blacklight_config.index.thumbnail_field]].flatten.first
    end
  end

  def count
    query_solr(query_params, rows: 0, facet: false)['response']['numFound']
  end

  def images
    response = query_solr(query_params,
      rows: 1000,
      fl: [blacklight_config.solr_document_model.unique_key, blacklight_config.index.title_field, blacklight_config.index.thumbnail_field],
      facet: false)

    Blacklight::SolrResponse.new(response, {}).docs.map do |result|
      doc = blacklight_config.solr_document_model.new(result)

      [
        doc.first(blacklight_config.solr_document_model.unique_key),
        doc.first(blacklight_config.index.title_field),
        doc.first(blacklight_config.index.thumbnail_field)
      ]
    end
  end

  def as_json(*args)
    super.merge(featured_image: featured_image, count: count)
  end

  def default_featured_item_id
    images.first.first if images.present?
  end

  def blacklight_config
    exhibit.blacklight_config
  end

  private
  def should_generate_new_friendly_id?
    title_changed?
  end

  
  alias_method :current_exhibit, :exhibit

end
