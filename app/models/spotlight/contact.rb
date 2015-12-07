module Spotlight
  ##
  # Exhibit curator contact information
  class Contact < ActiveRecord::Base
    belongs_to :exhibit, touch: true
    scope :published, -> { where(show_in_sidebar: true) }
    default_scope { order('weight ASC') }
    serialize :contact_info, Hash

    extend FriendlyId
    friendly_id :name, use: [:slugged, :scoped, :finders], scope: :exhibit

    mount_uploader :avatar, Spotlight::AvatarUploader

    before_save do
      self.contact_info = contact_info.symbolize_keys
    end

    ## carrierwave-crop doesn't want to store the crop points. we do.
    # so instead of this:
    # crop_uploaded :avatar  ## Add this
    # we do this:
    after_save do
      if avatar.present?
        avatar.cache! unless avatar.cached?
        avatar.store!
        recreate_avatar_versions
      end
    end

    before_save on: :create do
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
