require 'roar/decorator'
require 'roar/json'
module Spotlight
  ##
  # Serialize mastheads and thumbnails
  class FeaturedImageRepresenter < Roar::Decorator
    include Roar::JSON
    (Spotlight::FeaturedImage.attribute_names - %w(id image)).each do |prop|
      property prop
    end

    property :image, exec_context: :decorator
    def image
      file = represented.image.file

      return unless file

      { filename: file.filename, content_type: file.content_type, content: Base64.encode64(file.read) }
    end

    def image=(file)
      represented.image = CarrierWave::SanitizedFile.new tempfile: StringIO.new(Base64.decode64(file['content'])),
                                                         filename: file['filename'],
                                                         content_type: file['content_type']
    end
  end
end
