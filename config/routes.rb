Spotlight::Engine.routes.draw do
  resources :attachments
  resource :contact_form, only: [:new, :create]

  resources :exhibits, only: [:edit, :update] do
    resources :searches, shallow: true do
      collection do
        patch :update_all
      end
    end
    resources :browse, only: [:index, :show]
    resources :catalog, only: [:index]
    get 'edit/metadata', on: :member, to: "exhibits#edit_metadata_fields"
    get 'edit/facets', on: :member, to: "exhibits#edit_facet_fields"

    resources :about, controller: "about_pages", as: "about_pages", shallow: true do
      collection do
        patch :update_all
      end
    end
    resources :feature, controller: "feature_pages", as: "feature_pages", shallow: true do
      collection do
        patch :update_all
      end
    end
    resources :home_page, controller: "home_pages", as: "home_pages", shallow: true
  end
end
