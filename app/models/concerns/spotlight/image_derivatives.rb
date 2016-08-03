module Spotlight
  ###
  # Stores the derivative configurations in #spotlight_image_derivatives.
  # A new derivative could theoretically be added by putting the
  # following in an initializer.
  # Spotlight::ImageDerivatives.spotlight_image_derivatives << {
  #   version: :my_version,
  #   field: :my_field
  # }
  module ImageDerivatives
    mattr_accessor :spotlight_image_derivatives
    # Set default derivative configurations
    self.spotlight_image_derivatives ||= [
      {
        field: Spotlight::Engine.config.try(:full_image_field)
      },
      {
        version: :thumb,
        field: Spotlight::Engine.config.try(:thumbnail_field)
      },
      {
        version: :square,
        field: Spotlight::Engine.config.try(:square_image_field)
      }
    ].reject { |v| v[:field].blank? }
  end
end
