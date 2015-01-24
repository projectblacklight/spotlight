module Spotlight
  module ConfigurableUploaderVersions
    def apply_spotlight_versions
      configured_versions.each do |version_config|
        version_config[:lambda].call
      end
    end

    def configured_versions
      @configured_versions ||= [
        {
          version: :thumb,
          field: Spotlight::Engine.config.try(:thumbnail_field),
          lambda: lambda {
            version :thumb do
              process :resize_to_fit => [400,400]
            end
          }
        },
        {
          version: :square,
          field: Spotlight::Engine.config.try(:square_image_field),
          lambda: lambda {
            version :square do
              process :resize_to_fill => [100,100]
            end
          }
        }
      ].reject{|v| v[:field].blank? }
    end
  end
end
