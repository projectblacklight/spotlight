require 'mail'
class Spotlight::Exhibit < ActiveRecord::Base

  extend FriendlyId
  friendly_id :title, use: [:slugged,:finders]

  # friendly id associations need to be 'destroy'ed to reap the slug history 
  has_many :searches, dependent: :destroy, extend: FriendlyId::FinderMethods
  has_many :pages, dependent: :destroy
  has_many :about_pages, extend: FriendlyId::FinderMethods
  has_many :feature_pages, extend: FriendlyId::FinderMethods
  has_one :home_page
  belongs_to :masthead, dependent: :destroy
  belongs_to :thumbnail, class_name: "Spotlight::FeaturedImage", dependent: :destroy

  has_many :users, through: :roles, class_name: '::User'
  has_many :custom_fields, dependent: :delete_all
  has_many :contacts, dependent: :delete_all       # These are the contacts who appear in the sidebar
  has_many :contact_emails, dependent: :delete_all # These are the contacts who get "Contact us" emails 
  has_many :main_navigations, dependent: :delete_all
  has_many :solr_document_sidecars, dependent: :delete_all
  has_many :roles, dependent: :delete_all
  has_many :attachments, dependent: :destroy

  has_one :blacklight_configuration, class_name: "Spotlight::BlacklightConfiguration", dependent: :delete
  has_many :resources

  accepts_nested_attributes_for :solr_document_sidecars
  accepts_nested_attributes_for :attachments
  accepts_nested_attributes_for :blacklight_configuration, update_only: true
  accepts_nested_attributes_for :searches
  accepts_nested_attributes_for :about_pages
  accepts_nested_attributes_for :feature_pages
  accepts_nested_attributes_for :home_page, update_only: true
  accepts_nested_attributes_for :masthead, update_only: true
  accepts_nested_attributes_for :thumbnail, update_only: true
  accepts_nested_attributes_for :main_navigations
  accepts_nested_attributes_for :contacts
  accepts_nested_attributes_for :contact_emails, reject_if: proc {|attr| attr['email'].blank?}
  accepts_nested_attributes_for :roles, allow_destroy: true, reject_if: proc {|attr| attr['user_key'].blank?}
  accepts_nested_attributes_for :custom_fields
  accepts_nested_attributes_for :resources

  delegate :blacklight_config, to: :blacklight_configuration

  serialize :facets, Array

  before_create :build_home_page
  after_create :initialize_config
  after_create :initialize_browse
  after_create :initialize_main_navigation
  before_save :sanitize_description

  after_destroy do
    # Touch the default exhibit to ensure caching knows that
    # the exhibits have changed.
    Spotlight::Exhibit.default.touch
  end

  validates :title, presence: true
  acts_as_tagger
  has_many :owned_taggings, class_name: "ActsAsTaggableOn::Tagging", as: :tagger
  accepts_nested_attributes_for :owned_taggings

  def main_about_page
    @main_about_page ||= about_pages.published.first
  end

  # Find or create the default exhibit
  def self.default
    self.find_or_create_by!(default: true) do |e|
      e.title = 'Default exhibit'.freeze
    end
  end

  def has_browse_categories?
    searches.published.any?
  end

  def to_s
    title
  end

  def import hash
    Spotlight::ExhibitExportSerializer.prepare(self).from_hash(hash)
    self
  end

  def solr_data
    { :"#{Spotlight::Engine.config.solr_fields.prefix}spotlight_exhibit_slug_#{slug}#{Spotlight::Engine.config.solr_fields.boolean_suffix}" => true }
  end

  def appearance
    Spotlight::Appearance.new(blacklight_configuration)
  end

  def analytics start_date = 1.month, path = nil
    return OpenStruct.new unless analytics_provider and analytics_provider.enabled?
    @analytics ||= {}
    @analytics[start_date] ||= begin
      analytics_provider.exhibit_data(path || self, start_date: start_date.ago)
    end
  end
  
  def page_analytics start_date = 1.month, path = nil
    return [] unless analytics_provider and analytics_provider.enabled?
    
    @page_analytics ||= {}
    @page_analytics[start_date] ||= begin
      analytics_provider.page_data(path || self, start_date: start_date.ago)
    end
  end

  def reindex_later
    Spotlight::ReindexJob.perform_later(self)
  end

  def uploaded_resource_fields
    Spotlight::Engine.config.upload_fields
  end

  protected

  def initialize_config
    self.blacklight_configuration ||= Spotlight::BlacklightConfiguration.create!
  end

  def initialize_browse
    return unless self.searches.blank?

    self.searches.create title: "All Exhibit Items",
      long_description: "All items in this exhibit."
  end

  def initialize_main_navigation
    self.default_main_navigations.each_with_index do |nav_type, weight|
      self.main_navigations.create nav_type: nav_type, weight: weight
    end
  end

  def sanitize_description
    self.description = ::Rails::Html::FullSanitizer.new.sanitize(description) if description_changed?
  end

  def default_main_navigations
    Spotlight::Engine.config.exhibit_main_navigation.dup
  end

  def analytics_provider
    Spotlight::Engine.config.analytics_provider
  end

end
