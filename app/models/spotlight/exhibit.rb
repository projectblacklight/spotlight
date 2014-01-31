require 'mail'
class Spotlight::Exhibit < ActiveRecord::Base
  DEFAULT = 'default'.freeze
  has_many :roles
  has_many :searches
  has_many :pages

  serialize :facets, Array
  serialize :contact_emails, Array

  before_save :sanitize_description
  validate :name, :title, presence: true
  validate :valid_emails

  # This is necessary so the form will draw as if we have nested attributes (fields_for).
  def contact_emails
    super.each do |e|
      def e.persisted?
        false
      end
    end
  end

  # The attributes setter is required so the form will draw as if we have nested attributes (fields_for)
  def contact_emails_attributes=(emails)
    attributes_collection = emails.is_a?(Hash) ? emails.values : emails
    self.contact_emails = attributes_collection.map {|e| e['email']}.reject(&:blank?)
  end
  
  def self.default
    self.where(name: DEFAULT).first || self.create!(name: DEFAULT, title: 'Default exhibit'.freeze)
  end

  protected

  def valid_emails
    contact_emails.each do |email|
      begin
        parsed = Mail::Address.new(email)
      rescue Mail::Field::ParseError => e
      end
      errors.add :contact_emails, "#{email} is not valid" unless !parsed.nil? && parsed.address == email && parsed.local != email #cannot be a local address
    end
  end

  def sanitize_description
    self.description = HTML::FullSanitizer.new.sanitize(description) if description_changed?
  end
end
