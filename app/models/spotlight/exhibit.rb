require 'mail'
class Spotlight::Exhibit < ActiveRecord::Base
  DEFAULT = 'default'.freeze
  has_many :roles
  serialize :facets, Array
  serialize :contact_emails, Array

  before_save :sanitize_description
  validate :name, :title, presence: true
  validate :valid_emails
  
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
