Spotlight::Engine.routes.draw do

  devise_for :contact_email, class_name: "Spotlight::ContactEmail", only: [:confirmations]

  resources :exhibits, path: '/', except: [:index, :show] do
    member do
      get 'exhibit', to: 'exhibits#show', as: 'get'
      get 'import', to: 'exhibits#import'
      post 'import', to: 'exhibits#process_import'
      patch 'import', to: 'exhibits#process_import'
    end

    resources :attachments, only: :create
    resource :contact_form, path: "contact", only: [:new, :create]
    resource :blacklight_configuration, only: [:update]

    resource :appearance, only: [:edit, :update]

    get 'edit/metadata', to: "blacklight_configurations#edit_metadata_fields"
    get 'edit/facets', to: "blacklight_configurations#edit_facet_fields"
    get 'metadata', to: 'blacklight_configurations#metadata_fields'
    get 'available_configurations', to: 'blacklight_configurations#available_configurations'

    blacklight_for :catalog, only: [:export]

    resources :catalog do
      collection do
        get 'admin'
        get 'new'
        get 'autocomplete'
      end

      get "facet/:id", :to => "catalog#facet", :as => "catalog_facet"

      put 'visiblity', to: "catalog#make_public"
      delete 'visiblity', to: "catalog#make_private"
    end

    resources :solr_document, only: [:edit], to: 'catalog#edit'

    resources :custom_fields

    resource :dashboard, only: :show

    resources :resources

    resources :resources_csvs, controller: 'resources/csv', path: 'csv_resources' do
      collection do
        get :template
      end
    end

    resources :searches do
      collection do
        patch :update_all
      end
      member do
        get :autocomplete
      end
    end
    resources :browse, only: [:index, :show]
    resources :tags, only: [:index, :destroy]

    resources :contacts, only: [:edit, :update, :destroy]
    resources :about_pages, path: 'about' do
      collection do
        patch 'contacts' => 'about_pages#update_contacts'
        resources :contacts, only: [:new, :create]
        patch :update_all
      end
    end
    resources :feature_pages, path: 'feature' do
      collection do
        patch :update_all
      end
    end
    resource :home_page, path: 'home', controller: "home_pages"

    resources :roles, path: 'users', only: [:index, :create, :destroy] do
      collection do
        patch :update_all
      end
    end
  end

  get '/:exhibit_id' => 'home_pages#show', as: :exhibit_root
end
