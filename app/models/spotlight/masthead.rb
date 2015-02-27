class Spotlight::Masthead < ActiveRecord::Base
  belongs_to :exhibit, touch: true
  mount_uploader :image, Spotlight::MastheadUploader

  after_save do
    recreate_image_versions if image.present?
  end

  def document
    return unless document_global_id && source == 'exhibit'
    @document ||= GlobalID::Locator.locate document_global_id
  end

  def display?
    self.display && image.cropped_masthead.present?
  end

end
