module ActionDispatch::Routing
  class Mapper

    def spotlight_root
      root to: "spotlight/default#index"
    end
  end
end
