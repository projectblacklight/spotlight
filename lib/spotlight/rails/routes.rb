module ActionDispatch::Routing
  class Mapper

    def spotlight_root
      root to: "spotlight/home_pages#show"
    end
  end
end