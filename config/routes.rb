Spotlight::Engine.routes.draw do
  resources :attachments
  resources :pages
  resources :exhibits, only: [] do
    collection do
      # Presently we are only building a single exhibit
      get "edit", to: 'exhibits#edit'
    end
  end

end
