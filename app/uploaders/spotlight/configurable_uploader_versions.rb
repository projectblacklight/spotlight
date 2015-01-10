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
          blacklight_config_field: :thumbnail_field,
          lambda: lambda {
            version :thumb do
              process :resize_to_fit => [400,400]
            end
          }
        },
        {
          version: :square,
          blacklight_config_field: :square_image_field,
          lambda: lambda {
            version :square do
              process :resize_to_fill => [100,100]
            end
          }
        }
      ]
    end
  end
end
