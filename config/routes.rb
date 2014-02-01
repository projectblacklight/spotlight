Spotlight::Engine.routes.draw do
  resources :attachments
  resources :exhibits, only: [:edit, :update] do
    resources :searches, only: [:create, :index, :edit, :destroy], shallow: true
    resources :about, controller: "about_pages", as: "about_pages"
    resources :feature, controller: "feature_pages", as: "feature_pages"
    resources :catalog, only: [:index]
    get 'edit/metadata', on: :member, to: "exhibits#edit_metadata_fields"
  end
end
