module ActionDispatch::Routing
  class Mapper

    def spotlight_root
      root to: "spotlight/home_pages#show", defaults: {id: Spotlight::Exhibit.default.home_page.id} 
    end
  end
end
