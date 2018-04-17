Spotlight::Engine.routes.draw do
  devise_for :contact_email, class_name: 'Spotlight::ContactEmail', only: [:confirmations]

  resources :contact_images, controller: :featured_images, only: :create
  resources :exhibit_thumbnails, controller: :featured_images, only: :create
  resources :mastheads, controller: :featured_images, only: :create
  resources :featured_images, only: :create

  resource :site, only: [:edit, :update] do
    collection do
      get '/tags', to: 'sites#tags'
    end
  end

  get '/exhibits/edit', to: 'sites#edit_exhibits', as: 'edit_site_exhibits'

  resources :admin_users, only: [:index, :create, :destroy]

  resources :exhibits, path: '/', except: [:show] do
    member do
      get 'exhibit', to: 'exhibits#show', as: 'get'
      post 'import', to: 'exhibits#process_import'
      patch 'import', to: 'exhibits#process_import'
      post 'reindex', to: 'exhibits#reindex'
    end

    resources :contact_email, only: [:destroy], defaults: { format: :json }
    resources :attachments, only: :create
    resource :contact_form, path: 'contact', only: [:new, :create]
    resource :blacklight_configuration, only: [:update]

    resource :appearance, only: [:edit, :update]

    resource :metadata_configuration, only: [:show, :edit, :update]
    resource :search_configuration, only: [:show, :edit, :update]
    resource :view_configuration, only: [:show]

    resources :filters, only: [:create, :update]
    resources :languages, only: [:create, :destroy]

    concern :searchable, Blacklight::Routes::Searchable.new

    resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
      concerns :searchable

      collection do
        get 'admin'
        get 'autocomplete'
      end
    end

    concern :exportable, Blacklight::Routes::Exportable.new

    resources :solr_documents, except: [:index], path: '/catalog', controller: 'catalog' do
      concerns :exportable

      member do
        put 'visibility', action: 'make_public'
        delete 'visibility', action: 'make_private'
        get 'manifest'
      end
    end

    resources :custom_fields

    resource :dashboard, only: [:show] do
      get :analytics
    end

    resources :resources do
      collection do
        get :monitor
        post :reindex_all
      end
    end

    resources :resources_uploads, controller: 'resources/upload', path: 'upload_resources', only: [:create]

    resources :resources_csv_uploads, controller: 'resources/csv_upload', path: 'upload_csv', only: [:create] do
      collection do
        get :template
      end
    end

    resources :iiif_harvesters, controller: 'resources/iiif_harvester', only: :create, as: 'resources_iiif_harvesters'

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

    resources :pages, only: [:update_all] do
      collection do
        patch :update_all
      end
    end
    resources :about_pages, path: 'about' do
      member do
        get :clone
      end
      collection do
        patch 'contacts' => 'about_pages#update_contacts'
        resources :contacts, only: [:new, :create]
        patch :update_all
      end
    end
    resources :feature_pages, path: 'feature' do
      member do
        get :clone
      end
      collection do
        patch :update_all
      end
    end
    resource :home_page, path: 'home', controller: 'home_pages' do
      member do
        get :clone
      end
    end
    post '/pages/:id/preview' => 'pages#preview', as: :preview_block
    get '/pages' => 'pages#index', constraints: { format: 'json' }

    resources :lock, only: [:destroy]

    resources :roles, path: 'users', only: [:index, :create, :destroy] do
      collection do
        patch :update_all
      end
    end
    post 'solr/update' => 'solr#update'
    resource :translations, only: [:edit, :update]
  end

  get '/:exhibit_id' => 'home_pages#show', as: :exhibit_root
  post 'versions/:id/revert' => 'versions#revert', as: :revert_version
end
