Spotlight::Engine.routes.draw do
  resources :attachments
  resource :contact_form, only: [:new, :create]

  get 'exhibits/:exhibit_id' => 'catalog#index'

  resources :contacts, only: [:edit, :update, :destroy]
  resources :exhibits, only: [:edit, :update] do
    resource :blacklight_configuration, only: [:update]

    get 'edit/metadata', to: "blacklight_configurations#edit_metadata_fields"
    get 'edit/facets', to: "blacklight_configurations#edit_facet_fields"

    resources :catalog, only: [:index, :show, :edit, :update] do
      collection do
        get 'admin'
      end

      put 'visiblity', to: "catalog#make_public"
      delete 'visiblity', to: "catalog#make_private"
    end

    resources :custom_fields, shallow: true

    resources :dashboard, only: :index

    resources :searches, shallow: true do
      collection do
        patch :update_all
      end
    end
    resources :browse, only: [:index, :show]
    resources :tags, only: [:index, :destroy]


    resources :about, controller: "about_pages", as: "about_pages", shallow: true do
      collection do
        patch 'contacts' => 'about_pages#update_contacts'
        resources :contacts, only: [:new, :create]
        patch :update_all
      end
    end
    resources :feature, controller: "feature_pages", as: "feature_pages", shallow: true do
      collection do
        patch :update_all
      end
    end
    resources :home_page, controller: "home_pages", as: "home_pages", shallow: true

    resources :roles, only: [:index, :create, :destroy] do
      collection do
        patch :update_all
      end
    end
  end
end
