Spotlight::Engine.routes.draw do
  resources :attachments
  resources :exhibits, only: [:edit, :update] do
    resources :searches, shallow: true
    resources :about, controller: "about_pages", as: "about_pages"
    resources :feature, controller: "feature_pages", as: "feature_pages"
    resources :catalog, only: [:index]
    get 'edit/metadata', on: :member, to: "exhibits#edit_metadata_fields"
    get 'edit/facets', on: :member, to: "exhibits#edit_facet_fields"
    collection do
      post :update_all_pages
    end
  end
end
