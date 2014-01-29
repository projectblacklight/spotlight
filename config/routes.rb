Spotlight::Engine.routes.draw do
  resources :attachments
  resources :pages
  resources :exhibits, only: [:edit, :update]
end
