class Spotlight::Masthead < Spotlight::FeaturedImage
  mount_uploader :image, Spotlight::MastheadUploader

  def display?
    self.display && image.cropped.present?
  end

end
