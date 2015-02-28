class Spotlight::Masthead < ActiveRecord::Base
  belongs_to :exhibit, touch: true
  mount_uploader :image, Spotlight::MastheadUploader

  after_save do
    recreate_image_versions if image.present?
  end

  def display?
    self.display && image.cropped_masthead.present?
  end

end
