# frozen_string_literal: true

Spotlight::Engine.routes.draw do
  devise_for :contact_email, class_name: 'Spotlight::ContactEmail', only: [:confirmations]

  resources :contact_images, controller: :featured_images, only: :create
  resources :exhibit_thumbnails, controller: :featured_images, only: :create
  resources :mastheads, controller: :featured_images, only: :create
  resources :featured_images, only: :create

  resource :site, only: %i[edit update] do
    collection do
      get '/tags', to: 'sites#tags'
    end
  end

  get '/exhibits/edit', to: 'sites#edit_exhibits', as: 'edit_site_exhibits'

  resources :admin_users, only: %i[index create update destroy] do
    member do
      delete 'remove_exhibit_roles'
    end
  end

  resources :exhibits, path: '/', except: [:show] do
    member do
      get 'exhibit', to: 'exhibits#show', as: 'get'
      post 'import', to: 'exhibits#process_import'
      patch 'import', to: 'exhibits#process_import'
      post 'reindex', to: 'exhibits#reindex'
    end

    resources :contact_email, only: [:destroy]
    resources :attachments, only: :create
    resource :contact_form, path: 'contact', only: %i[new create]
    resource :blacklight_configuration, only: [:update]

    resource :appearance, only: %i[edit update]

    resource :metadata_configuration, only: %i[show edit update]
    resource :search_configuration, only: %i[show edit update]
    resource :view_configuration, only: [:show]

    resources :filters, only: %i[create update]
    resources :languages, only: %i[create destroy]

    concern :searchable, Blacklight::Routes::Searchable.new

    resource :catalog, only: [], as: 'catalog', path: '/catalog', controller: 'catalog' do
      concerns :searchable

      collection do
        get 'admin'
        get 'autocomplete'
      end
    end

    concern :exportable, Blacklight::Routes::Exportable.new

    resources :solr_documents,
              except: [:index],
              path: '/catalog',
              controller: 'catalog',
              **Spotlight::Engine.config.routes.solr_documents do
      concerns :exportable

      member do
        put 'visibility', action: 'make_public'
        delete 'visibility', action: 'make_private'
        get 'manifest'
      end
    end

    resources :custom_fields
    resources :custom_search_fields

    resource :dashboard, only: [:show] do
      get :analytics
    end

    get '/accessibility/alt-text', to: 'accessibility#alt_text', as: 'alt_text'

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
    get 'browse/:browse_category_id', to: 'catalog#index', constraints: ->(req) { req.format != :html }
    resources :browse, only: %i[index show]
    get 'browse/group/:group_id', to: 'browse#index', as: 'browse_groups'
    get 'browse/group/:group_id/:id', to: 'browse#show', as: 'browse_group'

    resources :groups, except: %i[show] do
      collection do
        patch :update_all
      end
    end

    resources :tags, only: %i[index destroy] do
      collection do
        patch :update_all
      end

      member do
        post :rename
      end
    end

    resources :contacts, only: %i[edit update destroy]

    resources :pages do
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
        resources :contacts, only: %i[new create]
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
    resource :bulk_actions, only: [] do
      member do
        post :change_visibility
        post :add_tags
        post :remove_tags
      end
    end

    resource :bulk_updates, only: %i[edit update] do
      collection do
        get :monitor
      end

      member do
        post :download_template
      end
    end

    post '/pages/:id/preview' => 'pages#preview', as: :preview_block
    get '/pages' => 'pages#index', constraints: { format: 'json' }

    resources :lock, only: [:destroy]
    resources :job_trackers, only: [:show]

    resources :roles, path: 'users', only: %i[index create destroy] do
      collection do
        patch :update_all
      end
    end
    post 'solr/update' => 'solr#update'
    resource :translations, only: %i[edit update show] do
      collection do
        post 'import'
        patch 'import'
      end
    end
    get 'iiif/collection' => 'catalog#index', defaults: { q: '*:*', format: :iiif_json }
  end

  get '/:exhibit_id' => 'home_pages#show', as: :exhibit_root
  post 'versions/:id/revert' => 'versions#revert', as: :revert_version

  get '/:exhibit_id/select_image' => 'catalog#select_image'
end
