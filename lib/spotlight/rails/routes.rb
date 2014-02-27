module ActionDispatch::Routing
  class Mapper

    def spotlight_root
      if Spotlight::Exhibit.table_exists?
        root to: "spotlight/home_pages#show", defaults: {exhibit_id: Spotlight::Exhibit.default.id} 
      else
        root to: "catalog#index"
      end
    end
  end
end
