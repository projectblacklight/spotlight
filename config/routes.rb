Spotlight::Engine.routes.draw do

  get '/:exhibit_id' => 'home_pages#show', as: :exhibit_root

  resources :exhibits, path: '/', only: [:edit, :update] do
    resources :attachments, only: :create
    resource :contact_form, path: "contact", only: [:new, :create]
    resource :blacklight_configuration, only: [:update]

    get 'edit/metadata', to: "blacklight_configurations#edit_metadata_fields"
    get 'edit/facets', to: "blacklight_configurations#edit_facet_fields"
    get 'metadata', to: 'blacklight_configurations#metadata_fields'

    resources :catalog do
      collection do
        get 'admin'
        get 'autocomplete'
      end

      put 'visiblity', to: "catalog#make_public"
      delete 'visiblity', to: "catalog#make_private"
    end

    resources :solr_document, only: [:edit], to: 'catalog#edit'

    resources :custom_fields

    resource :dashboard, only: :show

    resources :searches do
      collection do
        patch :update_all
      end
    end
    resources :browse, only: [:index, :show]
    resources :tags, only: [:index, :destroy]

    resources :contacts, only: [:edit, :update, :destroy]
    resources :about, controller: "about_pages", as: "about_pages" do
      collection do
        patch 'contacts' => 'about_pages#update_contacts'
        resources :contacts, only: [:new, :create]
        patch :update_all
      end
    end
    resources :feature, controller: "feature_pages", as: "feature_pages" do
      collection do
        patch :update_all
      end
    end
    resources :home_page, controller: "home_pages", as: "home_pages"

    resources :roles, only: [:index, :create, :destroy] do
      collection do
        patch :update_all
      end
    end
  end
end
