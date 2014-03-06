module ActionDispatch::Routing
  class Mapper

    def spotlight_root
      if Spotlight::Exhibit.table_exists? && FriendlyId::Slug.table_exists?
        root to: "spotlight/home_pages#show", defaults: {exhibit_id: Spotlight::ExhibitFactory.default.to_param} 
      else
        root to: "catalog#index"
      end
    end
  end
end
