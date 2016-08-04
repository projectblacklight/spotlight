module Migration
  # This migrates FeaturedImages with crop coordinates into IIIF urls which
  # are stored in the `iiif_url' field.
  module IIIF
    def self.run(hostname)
      Spotlight::FeaturedImage.all.each do |image|
        update_iiif_url(hostname, image)
      end
    end

    def self.update_iiif_url(hostname, image)
      image.update(iiif_url: iiif_url(hostname, image))
    end

    def self.iiif_url(hostname, image)
      "#{hostname}/images/#{image.id}/#{coordinates(image)}/#{size(image)}/0/default.jpg"
    end

    def self.size(image)
      case image
      when Spotlight::Masthead
        '1440,'
      else
        "#{image.image_crop_w},#{image.image_crop_h}"
      end
    end

    def self.coordinates(image)
      [image.image_crop_x, image.image_crop_y, image.image_crop_w, image.image_crop_h].join(',')
    end
  end
end
