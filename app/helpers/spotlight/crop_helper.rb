module Spotlight
  ##
  # iiif-crop options helpers
  module CropHelper
    def iiif_cropper(form, name, height, width)
      IIIFCropper.new(form, name, height, width)
    end

    def contact_crop(form, name)
      w, h = Spotlight::Engine.config.contact_square_size
      iiif_cropper(form, name, w, h).draw
    end
  end
end
