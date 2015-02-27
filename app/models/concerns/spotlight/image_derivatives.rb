module Spotlight
  module ImageDerivatives
    mattr_accessor :spotlight_image_derivatives

    def apply_spotlight_image_derivative_versions
      @@spotlight_image_derivatives.each do |version_config|
        if(c = version_config[:lambda]).present?
          class_eval(&c)
        end
      end
    end

    self.spotlight_image_derivatives ||= [
      {
        field: Spotlight::Engine.config.try(:full_image_field)
      },
      {
        version: :thumb,
        field: Spotlight::Engine.config.try(:thumbnail_field),
        lambda: lambda {|_|
          version :thumb do
            process :resize_to_fit => [400,400]
          end
        }
      },
      {
        version: :square,
        field: Spotlight::Engine.config.try(:square_image_field),
        lambda: lambda {|_|
          version :square do
            process :resize_to_fill => [100,100]
          end
        }
      }
    ].reject{|v| v[:field].blank? }
  end
end
