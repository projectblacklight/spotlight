module ActionDispatch::Routing
  class Mapper

    def spotlight_root
      root to: "spotlight/home_pages#show", defaults: {exhibit_id: Spotlight::Exhibit.default_route_key} 
    end
  end
end
