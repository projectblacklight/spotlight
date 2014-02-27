require 'mail'
class Spotlight::Exhibit < ActiveRecord::Base

  extend FriendlyId
  friendly_id :title, use: [:slugged,:finders]

  DEFAULT = 'default'.freeze
  has_many :roles
  has_many :searches
  has_many :pages
  has_many :about_pages
  has_many :feature_pages
  has_one :home_page
  has_many :home_pages
  has_many :users, through: :roles, class_name: '::User'
  has_many :custom_fields
  has_many :contacts       # These are the contacts who appear in the sidebar
  has_many :contact_emails # These are the contacts who get "Contact us" emails 
  has_many :attachments
  has_one :blacklight_configuration, class_name: Spotlight::BlacklightConfiguration

  accepts_nested_attributes_for :blacklight_configuration
  accepts_nested_attributes_for :searches
  accepts_nested_attributes_for :about_pages
  accepts_nested_attributes_for :feature_pages
  accepts_nested_attributes_for :contacts
  accepts_nested_attributes_for :contact_emails
  accepts_nested_attributes_for :roles, allow_destroy: true, reject_if: proc {|attr| attr['user_key'].blank?}
  delegate :blacklight_config, to: :blacklight_configuration

  serialize :facets, Array

  before_create :initialize_config
  before_create :initialize_browse
  after_create :add_default_home_page
  before_save :sanitize_description
  validate :name, :title, presence: true
  acts_as_tagger

  def main_about_page
    @main_about_page ||= about_pages.published.first
  end

  # Find or create the default exhibit
  def self.default
    self.find_or_create_by!(name: DEFAULT) do |e|
      e.title = 'Default exhibit'.freeze
    end
  end

  def has_browse_categories?
    searches.published.any?
  end

  def to_s
    title
  end

  protected

  def initialize_config
    self.blacklight_configuration ||= Spotlight::BlacklightConfiguration.create!
  end

  def initialize_browse
    return unless self.searches.blank?

    self.searches.build title: "Browse All Exhibit Items",
      short_description: "Search results for all items in this exhibit",
      long_description: "All items in this exhibit"
  end

  def add_default_home_page
    Spotlight::HomePage.create(exhibit: self).save
  end

  def sanitize_description
    self.description = HTML::FullSanitizer.new.sanitize(description) if description_changed?
  end
end
