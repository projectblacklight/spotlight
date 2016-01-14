Spotlight::Resources::Iiif::Engine.routes.draw do
  resources :exhibits, only: [] do
    resource :iiif_harvester, controller: :"spotlight/resources/iiif_harvester", only: :create, as: :resources_iiif_harvesters
  end
end
