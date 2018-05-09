module Spotlight
  ##
  # Exhibit saved searches
  class Search < ActiveRecord::Base
    include Spotlight::Translatables
    extend FriendlyId
    friendly_id :title, use: [:slugged, :scoped, :finders, :history], scope: :exhibit

    self.table_name = 'spotlight_searches'
    belongs_to :exhibit
    serialize :query_params, Hash
    default_scope { order('weight ASC') }
    scope :published, -> { where(published: true) }
    validates :title, presence: true

    translates :title, :long_description

    has_paper_trail

    belongs_to :masthead, dependent: :destroy, optional: true
    belongs_to :thumbnail, class_name: 'Spotlight::FeaturedImage', dependent: :destroy, optional: true
    accepts_nested_attributes_for :thumbnail, update_only: true, reject_if: proc { |attr| attr['iiif_tilesource'].blank? }
    accepts_nested_attributes_for :masthead, update_only: true, reject_if: proc { |attr| attr['iiif_tilesource'].blank? }

    def thumbnail_image_url
      return unless thumbnail && thumbnail.iiif_url
      thumbnail.iiif_url
    end

    def documents
      start = 0
      response = repository.search(search_params.start(start))

      return to_enum(:documents) { response['response']['numFound'] } unless block_given?

      while response.documents.present?
        response.documents.each { |x| yield x }
        start += response.documents.length
        response = repository.search(search_params.start(start))
      end
    end

    def count
      documents.size
    end

    delegate :blacklight_config, to: :exhibit

    def display_masthead?
      masthead && masthead.display?
    end

    def search_params
      search_builder.with(query_params.with_indifferent_access).merge(facet: false, fl: default_search_fields)
    end

    def merge_params_for_search(params, blacklight_config)
      base_query = Blacklight::SearchState.new(query_params, blacklight_config)
      user_query = Blacklight::SearchState.new(params, blacklight_config).to_h
      base_query.params_for_search(user_query).merge(user_query.slice(:page))
    end

    private

    def search_builder_class
      blacklight_config.search_builder_class
    end

    def search_builder
      search_builder_class.new(self)
    end

    def repository
      @repository ||= Blacklight::Solr::Repository.new(blacklight_config)
    end

    def default_search_fields
      [
        blacklight_config.document_model.unique_key,
        blacklight_config.index.title_field,
        blacklight_config.index.thumbnail_field
      ].compact
    end

    def should_generate_new_friendly_id?
      super || (title_changed? && persisted?)
    end

    alias current_exhibit exhibit
  end
end
