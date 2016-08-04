module Migration
  # This migrates FeaturedImages with crop coordinates into IIIF urls which
  # are stored in the `iiif_url' field.
  class IIIF
    def self.run(hostname)
      new(hostname).run
    end

    def initialize(hostname)
      @hostname = hostname
    end

    def run
      migrate_featured_images
      migrate_contact_avatars
    end

    attr_reader :hostname

    def iiif_url(image)
      riiif.image_url(image.id,
                      region: coordinates(image),
                      size: size(image),
                      host: hostname)
    end

    private

    def riiif
      Riiif::Engine.routes.url_helpers
    end

    def migrate_featured_images
      Spotlight::FeaturedImage.all.each do |image|
        update_iiif_url(image)
      end
    end

    def migrate_contact_avatars
      Spotlight::Contact.all.each do |contact|
        avatar = copy_contact_image_to_avatar(contact)
        contact.update(avatar: avatar)
      end
    end

    # Looks for a file at the old uploader location and copies it to a FeaturedImage
    def copy_contact_image_to_avatar(contact)
      filename = contact.read_attribute_before_type_cast('avatar')
      filepath = "public/uploads/spotlight/contact/avatar/#{contact.id}/#{filename}"
      old_file = File.new(filepath)
      image = contact.create_avatar { |i| i.image.store!(old_file) }
      iiif_url = riiif.image_url(image.id,
                                 region: avatar_coordinates(contact),
                                 size: avatar_size(contact),
                                 host: hostname)
      image.update(iiif_url: iiif_url)
      image
    end

    def update_iiif_url(image)
      image.update(iiif_url: iiif_url(image))
    end

    def size(image)
      case image
      when Spotlight::Masthead
        '1440,'
      else
        "#{image.image_crop_w},#{image.image_crop_h}"
      end
    end

    def coordinates(image)
      [image.image_crop_x, image.image_crop_y, image.image_crop_w, image.image_crop_h].join(',')
    end

    def avatar_size(contact)
      "#{contact.avatar_crop_w},#{contact.avatar_crop_h}"
    end

    def avatar_coordinates(contact)
      [contact.avatar_crop_x, contact.avatar_crop_y, contact.avatar_crop_w, contact.avatar_crop_h].join(',')
    end
  end
end
