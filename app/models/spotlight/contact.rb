class Spotlight::Contact < ActiveRecord::Base
  belongs_to :exhibit, touch: true
  scope :published, -> { where(show_in_sidebar: true) }
  default_scope { order("weight ASC") }
  serialize :contact_info, Hash

  extend FriendlyId
  friendly_id :name, use: [:slugged,:scoped,:finders], scope: :exhibit

  mount_uploader :avatar, AvatarUploader

  ## carrierwave-crop doesn't want to store the crop points. we do.
  # so instead of this:
  #crop_uploaded :avatar
  # we do this:
  #recreate_avatar_versions if avatar.present?
  after_save do
    touch_about_pages
    recreate_avatar_versions if avatar.present?
  end

  before_save on: :create do
    self.show_in_sidebar = true if show_in_sidebar.nil?
  end

  def self.fields
    @fields ||= {title:     {itemprop: 'jobTitle'},
                 location:  {itemprop: 'workLocation'},
                 email:     {helper: :render_contact_email_address},
                 telephone: {}}
  end

  protected
  def should_generate_new_friendly_id?
    name_changed?
  end

  def touch_about_pages
    exhibit.about_pages.map(&:touch)
  end
end
