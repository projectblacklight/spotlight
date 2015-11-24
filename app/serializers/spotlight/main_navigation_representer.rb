module Spotlight
  ##
  # Serialize the Spotlight::BlacklightConfiguration
  class MainNavigationRepresenter < Roar::Decorator
    include Roar::JSON

    (Spotlight::MainNavigation.attribute_names - %w(id exhibit_id)).each do |prop|
      property prop
    end
  end
end
