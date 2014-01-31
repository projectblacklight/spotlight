Spotlight::Engine.routes.draw do
  resources :attachments
  resources :exhibits, only: [:edit, :update] do
    resources :pages, shallow: true
    resources :searches, only: [:create]
    resources :catalog, only: [:index]
  end
end
