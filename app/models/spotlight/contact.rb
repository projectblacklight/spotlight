# frozen_string_literal: true

module Spotlight
  ##
  # Exhibit curator contact information
  class Contact < ActiveRecord::Base
    belongs_to :exhibit, touch: true, optional: true
    scope :published, -> { where(show_in_sidebar: true) }
    default_scope { order('weight ASC') }
    if Rails.version > '7.1'
      serialize :contact_info, type: Hash, coder: YAML
    else
      serialize :contact_info, Hash, coder: YAML
    end
    extend FriendlyId
    friendly_id :name, use: %i[slugged scoped finders], scope: :exhibit

    belongs_to :avatar, class_name: 'Spotlight::ContactImage', dependent: :destroy, optional: true
    accepts_nested_attributes_for :avatar, update_only: true, reject_if: proc { |attr| attr['iiif_tilesource'].blank? }

    before_save do
      self.contact_info = contact_info.symbolize_keys
    end

    before_create do
      self.show_in_sidebar = true if show_in_sidebar.nil?
    end

    def self.fields
      @fields ||= { title: { itemprop: 'jobTitle' },
                    location: { itemprop: 'workLocation' },
                    email: { helper: :render_contact_email_address },
                    telephone: {} }
    end

    protected

    def should_generate_new_friendly_id?
      super || (name_changed? && persisted?)
    end
  end
end
