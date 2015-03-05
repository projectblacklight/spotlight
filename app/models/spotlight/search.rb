class Spotlight::Search < ActiveRecord::Base

  extend FriendlyId
  friendly_id :title, use: [:slugged,:scoped,:finders,:history], scope: :exhibit

  self.table_name = 'spotlight_searches'
  belongs_to :exhibit
  serialize :query_params, Hash
  default_scope { order("weight ASC") }
  scope :published, -> { where(on_landing_page: true) }
  validates :title, presence: true
  has_paper_trail
  
  belongs_to :masthead, dependent: :destroy
  belongs_to :thumbnail, class_name: "Spotlight::FeaturedImage", dependent: :destroy
  accepts_nested_attributes_for :thumbnail, update_only: true
  accepts_nested_attributes_for :masthead, update_only: true


  before_create :set_default_featured_image

  include Blacklight::SolrHelper
  include Spotlight::Catalog::AccessControlsEnforcement

  def thumbnail_image_url
    thumbnail.image.cropped.url if thumbnail and thumbnail.image
  end

  def count
    query_solr(query_params, rows: 0, facet: false)['response']['numFound']
  end

  def images
    documents.map do |doc|

      [
        doc.first(blacklight_config.solr_document_model.unique_key),
        doc.first(blacklight_config.index.title_field),
        doc.first(blacklight_config.index.thumbnail_field)
      ]
    end
  end

  def documents
    return enum_for(:documents) unless block_given?

    Blacklight::SolrResponse.new(solr_response, {}).docs.each do |result|
      yield blacklight_config.solr_document_model.new(result)
    end
  end

  def blacklight_config
    exhibit.blacklight_config
  end

  def display_masthead?
    masthead && masthead.display?
  end

  private
  def solr_response
    @solr_response ||= query_solr(query_params,
      rows: 1000,
      fl: [blacklight_config.solr_document_model.unique_key, blacklight_config.index.title_field, blacklight_config.index.thumbnail_field, Spotlight::Engine.config.full_image_field],
      facet: false)
  end
  def should_generate_new_friendly_id?
    title_changed?
  end

  def set_default_featured_image
    self.thumbnail ||= begin
      if doc = documents.first
        self.create_thumbnail source: 'exhibit', document_global_id: doc.to_global_id.to_s, remote_image_url: doc.first(Spotlight::Engine.config.full_image_field)
      end
    end
  end

  
  alias_method :current_exhibit, :exhibit

end
