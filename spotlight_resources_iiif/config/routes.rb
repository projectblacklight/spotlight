Spotlight::Resources::Iiif::Engine.routes.draw do
  resources :exhibits, only: [] do
    resources :iiif_harvesters, controller: :"spotlight/resources/iiif_harvester", only: :create, as: 'resources_iiif_harvesters'
  end
end
