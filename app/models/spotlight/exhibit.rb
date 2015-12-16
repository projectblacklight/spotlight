require 'mail'
module Spotlight
  ##
  # Spotlight exhibit
  class Exhibit < ActiveRecord::Base
    include Spotlight::ExhibitAnalytics
    include Spotlight::ExhibitDocuments

    scope :published, -> { where(published: true) }
    scope :unpublished, -> { where(published: false) }

    extend FriendlyId
    friendly_id :title, use: [:slugged, :finders]
    validates :title, presence: true

    default_scope { order('weight ASC') }

    acts_as_tagger
    delegate :blacklight_config, to: :blacklight_configuration
    serialize :facets, Array

    # Note: friendly id associations need to be 'destroy'ed to reap the slug history
    has_many :about_pages, extend: FriendlyId::FinderMethods
    has_many :attachments, dependent: :destroy
    has_many :contact_emails, dependent: :delete_all # These are the contacts who get "Contact us" emails
    has_many :contacts, dependent: :delete_all # These are the contacts who appear in the sidebar
    has_many :custom_fields, dependent: :delete_all
    has_many :feature_pages, extend: FriendlyId::FinderMethods
    has_many :main_navigations, dependent: :delete_all
    has_many :owned_taggings, class_name: 'ActsAsTaggableOn::Tagging', as: :tagger
    has_many :resources
    has_many :roles, dependent: :delete_all
    has_many :searches, dependent: :destroy, extend: FriendlyId::FinderMethods
    has_many :solr_document_sidecars, dependent: :delete_all
    has_many :users, through: :roles, class_name: Spotlight::Engine.config.user_class
    has_many :pages, dependent: :destroy

    has_one :blacklight_configuration, class_name: 'Spotlight::BlacklightConfiguration', dependent: :delete
    has_one :home_page

    belongs_to :site
    belongs_to :masthead, dependent: :destroy
    belongs_to :thumbnail, class_name: 'Spotlight::FeaturedImage', dependent: :destroy

    accepts_nested_attributes_for :about_pages, :attachments, :contacts, :custom_fields, :feature_pages,
                                  :main_navigations, :owned_taggings, :resources, :searches, :solr_document_sidecars
    accepts_nested_attributes_for :blacklight_configuration, :home_page, :masthead, :thumbnail, update_only: true
    accepts_nested_attributes_for :contact_emails, reject_if: proc { |attr| attr['email'].blank? }
    accepts_nested_attributes_for :roles, allow_destroy: true, reject_if: proc { |attr| attr['user_key'].blank? }

    before_save :sanitize_description, if: :description_changed?
    before_create :build_home_page
    before_create :add_site_reference
    after_create :initialize_config
    after_create :initialize_browse
    after_create :initialize_main_navigation
    include Spotlight::DefaultThumbnailable

    scope :published, -> { where(published: true) }

    def main_about_page
      @main_about_page ||= about_pages.published.first
    end

    def browse_categories?
      searches.published.any?
    end

    def to_s
      title
    end

    def import(hash)
      Spotlight::ExhibitExportSerializer.prepare(self).from_hash(hash)
      self
    end

    def solr_data
      Spotlight::Engine.config.exhibit_filter.call(self)
    end

    def reindex_later
      Spotlight::ReindexJob.perform_later(self)
    end

    def uploaded_resource_fields
      Spotlight::Engine.config.upload_fields
    end

    def searchable?
      blacklight_config.search_fields.any? { |_k, v| v.enabled && v.include_in_simple_select != false }
    end

    def set_default_thumbnail
      self.thumbnail ||= searches.first.try(:thumbnail)
    end

    def requested_by
      roles.first.user if roles.first
    end

    def reindex_progress
      @reindex_progress ||= ReindexProgress.new(resources.order('updated_at')) if resources
    end

    protected

    def add_site_reference
      self.site ||= Spotlight::Site.instance
    end

    def initialize_config
      self.blacklight_configuration ||= Spotlight::BlacklightConfiguration.create!
    end

    def initialize_browse
      return unless searches.blank?

      searches.create title: 'All Exhibit Items',
                      long_description: 'All items in this exhibit.'
    end

    def initialize_main_navigation
      default_main_navigations.each_with_index do |nav_type, weight|
        main_navigations.create nav_type: nav_type, weight: weight
      end
    end

    def sanitize_description
      self.description = ::Rails::Html::FullSanitizer.new.sanitize(description)
    end

    def default_main_navigations
      Spotlight::Engine.config.exhibit_main_navigation.dup
    end
  end
end
