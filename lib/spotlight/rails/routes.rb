module Spotlight
  ##
  # Spotlight routing helpers
  module Routes
    def spotlight_root
      root to: 'spotlight/default#index'
    end
  end
end

ActionDispatch::Routing::Mapper.send :include, Spotlight::Routes
