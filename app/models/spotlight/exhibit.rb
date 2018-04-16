require 'mail'
module Spotlight
  ##
  # Spotlight exhibit
  class Exhibit < ActiveRecord::Base
    include Spotlight::ExhibitAnalytics
    include Spotlight::ExhibitDefaults
    include Spotlight::ExhibitDocuments

    has_paper_trail

    scope :published, -> { where(published: true) }
    scope :unpublished, -> { where(published: false) }
    scope :ordered_by_weight, -> { order('weight ASC') }

    paginates_per 48

    extend FriendlyId
    friendly_id :title, use: [:slugged, :finders]
    validates :title, presence: true
    validates :slug, uniqueness: true
    validates :theme, inclusion: { in: Spotlight::Engine.config.exhibit_themes }, allow_blank: true

    acts_as_tagger
    acts_as_taggable
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
    has_many :reindexing_log_entries, dependent: :destroy
    has_many :resources
    has_many :roles, as: :resource, dependent: :delete_all
    has_many :searches, dependent: :destroy, extend: FriendlyId::FinderMethods
    has_many :solr_document_sidecars, dependent: :delete_all
    has_many :users, through: :roles, class_name: Spotlight::Engine.config.user_class
    has_many :pages, dependent: :destroy
    has_many :filters, dependent: :delete_all
    has_many :translations, class_name: 'I18n::Backend::ActiveRecord::Translation', dependent: :destroy, inverse_of: :exhibit

    has_one :blacklight_configuration, class_name: 'Spotlight::BlacklightConfiguration', dependent: :delete
    has_one :home_page

    belongs_to :site, optional: true
    belongs_to :masthead, dependent: :destroy, optional: true
    belongs_to :thumbnail, class_name: 'Spotlight::ExhibitThumbnail', dependent: :destroy, optional: true

    accepts_nested_attributes_for :about_pages, :attachments, :contacts, :custom_fields, :feature_pages,
                                  :main_navigations, :owned_taggings, :resources, :searches, :solr_document_sidecars
    accepts_nested_attributes_for :blacklight_configuration, :home_page, :filters, update_only: true
    accepts_nested_attributes_for :masthead, :thumbnail, update_only: true, reject_if: proc { |attr| attr['iiif_tilesource'].blank? }
    accepts_nested_attributes_for :contact_emails, reject_if: proc { |attr| attr['email'].blank? }
    accepts_nested_attributes_for :roles, allow_destroy: true, reject_if: proc { |attr| attr['user_key'].blank? && attr['id'].blank? }

    before_save :sanitize_description, if: :description_changed?

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
      filters.each_with_object({}) do |filter, hash|
        hash.merge! filter.to_hash
      end
    end

    def reindex_later(user = nil)
      Spotlight::ReindexJob.perform_later(self, new_reindexing_log_entry(user))
    end

    def uploaded_resource_fields
      Spotlight::Engine.config.upload_fields
    end

    def searchable?
      blacklight_config.search_fields.any? { |_k, v| v.enabled && v.include_in_simple_select != false }
    end

    def requested_by
      roles.first.user if roles.first
    end

    def reindex_progress
      @reindex_progress ||= ReindexProgress.new(current_reindexing_log_entry)
    end

    protected

    def sanitize_description
      self.description = ::Rails::Html::FullSanitizer.new.sanitize(description)
    end

    def new_reindexing_log_entry(user = nil)
      Spotlight::ReindexingLogEntry.create(exhibit: self, user: user, items_reindexed_count: 0, job_status: 'unstarted')
    end

    private

    def current_reindexing_log_entry
      reindexing_log_entries.started_or_completed.first || reindexing_log_entries.build
    end
  end
end
