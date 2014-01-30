Spotlight::Engine.routes.draw do
  resources :attachments
  resources :exhibits, only: [:edit, :update] do
    resources :pages, shallow: true
    resources :searches, only: [:create]
    resources :catalog, only: [:index]
    get 'edit/metadata', on: :member, to: "exhibits#edit_metadata_fields"
  end
end
