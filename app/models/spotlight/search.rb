module Spotlight
  ##
  # Exhibit saved searches
  class Search < ActiveRecord::Base
    include DefaultThumbnailable
    extend FriendlyId
    friendly_id :title, use: [:slugged, :scoped, :finders, :history], scope: :exhibit

    self.table_name = 'spotlight_searches'
    belongs_to :exhibit
    serialize :query_params, Hash
    default_scope { order('weight ASC') }
    scope :published, -> { where(published: true) }
    validates :title, presence: true
    has_paper_trail

    belongs_to :masthead, dependent: :destroy
    belongs_to :thumbnail, class_name: 'Spotlight::FeaturedImage', dependent: :destroy
    accepts_nested_attributes_for :thumbnail, update_only: true
    accepts_nested_attributes_for :masthead, update_only: true

    def thumbnail_image_url
      thumbnail.image.thumb.url if thumbnail && thumbnail.image
    end

    def count
      repository.search(search_params.rows(0))['response']['numFound']
    end

    def images
      documents.map do |doc|
        [
          doc.first(blacklight_config.document_model.unique_key),
          doc.first(blacklight_config.index.title_field),
          doc.first(blacklight_config.index.thumbnail_field)
        ]
      end
    end

    def documents
      return enum_for(:documents) unless block_given?

      Blacklight::Solr::Response.new(solr_response, {}).docs.each do |result|
        yield blacklight_config.document_model.new(result)
      end
    end

    delegate :blacklight_config, to: :exhibit

    def display_masthead?
      masthead && masthead.display?
    end

    def set_default_thumbnail
      self.thumbnail ||= begin
        doc = documents.detect { |x| x.first(Spotlight::Engine.config.full_image_field) }
        if doc
          create_thumbnail(
            source: 'exhibit',
            document_global_id: doc.to_global_id.to_s,
            remote_image_url: doc.first(Spotlight::Engine.config.full_image_field)
          )
        end
      end
    end

    def search_params
      search_builder.with(query_params.with_indifferent_access).merge(facet: false)
    end

    private

    def search_builder_class
      blacklight_config.search_builder_class
    end

    def search_builder
      search_builder_class.new(true, self)
    end

    def repository
      Blacklight.default_index
    end

    def solr_response
      @solr_response ||= repository.search(search_params.rows(1000).merge(fl: default_search_fields))
    end

    def default_search_fields
      [
        blacklight_config.document_model.unique_key,
        blacklight_config.index.title_field,
        blacklight_config.index.thumbnail_field,
        Spotlight::Engine.config.full_image_field
      ]
    end

    def should_generate_new_friendly_id?
      super || (title_changed? && persisted?)
    end

    alias_method :current_exhibit, :exhibit
  end
end
