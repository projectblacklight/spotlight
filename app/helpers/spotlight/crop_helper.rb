module Spotlight
  ##
  # iiif-crop options helpers
  module CropHelper
    def iiif_cropper(form, name, width, height)
      IIIFCropper.new(form, name, width, height)
    end

    def contact_crop(form, name)
      w, h = Spotlight::Engine.config.contact_square_size
      iiif_cropper(form, name, w, h).draw
    end
  end
end
