# frozen_string_literal: true

# Load blacklight which will give spotlight views a higher preference than those in blacklight

# devise must be required to first to ensure we can override devise and invitable views in spotlight correctly
require 'devise'
require 'devise_invitable'

require 'activejob-status'
require 'blacklight'
require 'faraday'
require 'faraday/follow_redirects'
require 'friendly_id'
require 'i18n/active_record'
require 'paper_trail'
require 'riiif'
require 'spotlight/riiif_service'
require 'spotlight/upload_field_config'

module Spotlight
  ##
  # Spotlight::Engine
  # rubocop:disable Metrics/ClassLength
  class Engine < ::Rails::Engine
    isolate_namespace Spotlight

    require 'carrierwave'
    require 'redcarpet' # required for markdown support
    require 'openseadragon'

    config.autoload_paths += %W[
      #{config.root}/app/builders
      #{config.root}/app/controllers/concerns
      #{config.root}/app/models/concerns
    ]

    initializer 'spotlight.initialize' do
      require 'cancan'
      require 'bootstrap_form'
      require 'acts-as-taggable-on'

      Mime::Type.register 'application/solr+json', :solr_json
      Mime::Type.register 'application/iiif+json', :iiif_json
    end

    initializer 'spotlight.factories', after: 'factory_bot.set_factory_paths' do
      FactoryBot.definition_file_paths << File.expand_path('../../spec/factories', __dir__) if defined?(FactoryBot)
    end

    PRECOMPILE_ASSETS = %w[
      spotlight/blocks/sir-trevor-icons.svg
      spotlight/default_thumbnail.jpg
      spotlight/default_browse_thumbnail.jpg
      spotlight/spotlight.js
      spotlight/spotlight.js.map
      spotlight/spotlight.esm.js
      spotlight/spotlight.esm.js.map
    ].freeze

    initializer 'spotlight.assets.precompile' do |app|
      app.config.assets.paths << Engine.root.join('app/javascript')
      app.config.assets.precompile += PRECOMPILE_ASSETS
    end

    initializer 'spotlight.importmap', before: 'importmap' do |app|
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << Engine.root.join('config/importmap.rb')
        app.config.importmap.cache_sweepers << Engine.root.join('app/javascript')
      end
    end

    # All Spotlight-specific configuration is encapsulated onto a single
    # +spotlight+ entry in the Rails configuration namespace, rather than
    # polluting the shared Railtie::Configuration namespace. Other railties
    # follow the same convention.
    spotlight_config = OpenStruct.new
    config.spotlight = spotlight_config

    def self.user_class
      Spotlight::Engine.config.spotlight.user_class.constantize
    end

    def self.catalog_controller
      Spotlight::Engine.config.spotlight.catalog_controller_class.constantize
    end

    def self.blacklight_config
      Spotlight::Engine.config.spotlight.default_blacklight_config || catalog_controller.blacklight_config
    end

    spotlight_config.user_class = '::User'

    spotlight_config.catalog_controller_class = '::CatalogController'
    spotlight_config.default_blacklight_config = nil

    spotlight_config.exhibit_main_navigation = %i[curated_features browse about]

    spotlight_config.resource_partials = [
      'spotlight/resources/external_resources_form',
      'spotlight/resources/upload/form',
      'spotlight/resources/csv_upload/form',
      'spotlight/resources/json_upload/form',
      'spotlight/resources/iiif/form'
    ]
    spotlight_config.external_resources_partials = []
    spotlight_config.solr_batch_size = 20

    spotlight_config.reindex_progress_window = 1.hour

    # Filter resources by exhibit by default
    spotlight_config.filter_resources_by_exhibit = true

    # Should Spotlight write to solr? If set to false, Spotlight will not initiate indexing.
    spotlight_config.writable_index = true

    # The allowed file extensions for uploading non-repository items.
    spotlight_config.allowed_upload_extensions = %w[jpg jpeg png]

    # IIIF integration
    spotlight_config.iiif_service = Spotlight::RiiifService

    # Suffixes for spotlight-created solr fields
    spotlight_config.solr_fields = OpenStruct.new
    spotlight_config.solr_fields.prefix = ''
    spotlight_config.solr_fields.boolean_suffix = '_bsi'
    spotlight_config.solr_fields.string_suffix = '_ssim'
    spotlight_config.solr_fields.text_suffix = '_tesim'

    # Suffixes for exhibit-specific solr fields
    spotlight_config.custom_field_types = {
      vocab: { suffix: '_ssim', facetable: true },
      text: { suffix: '_tesim' }
    }

    spotlight_config.resource_global_id_field = :"#{spotlight_config.solr_fields.prefix}spotlight_resource_id#{spotlight_config.solr_fields.string_suffix}"
    spotlight_config.job_tracker_id_field = :"#{spotlight_config.solr_fields.prefix}spotlight_job_tracker_id#{spotlight_config.solr_fields.string_suffix}"

    # Set to nil if you don't want to pull thumbnails from the index
    spotlight_config.full_image_field = :full_image_url_ssm
    spotlight_config.thumbnail_field = :thumbnail_url_ssm

    spotlight_config.site_tags = nil

    # Defaults to the blacklight_config.index.title_field:
    spotlight_config.upload_title_field = nil # UploadFieldConfig.new(...)
    spotlight_config.upload_description_field = :spotlight_upload_description_tesim

    spotlight_config.upload_fields = [
      UploadFieldConfig.new(
        field_name: spotlight_config.upload_description_field,
        label: -> { I18n.t(:"spotlight.search.fields.#{Spotlight::Engine.config.spotlight.upload_description_field}") },
        form_field_type: :text_area
      ),
      UploadFieldConfig.new(
        field_name: :spotlight_upload_attribution_tesim,
        label: -> { I18n.t(:'spotlight.search.fields.spotlight_upload_attribution_tesim') }
      ),
      UploadFieldConfig.new(
        field_name: :spotlight_upload_date_tesim,
        label: -> { I18n.t(:'spotlight.search.fields.spotlight_upload_date_tesim') }
      )
    ]

    spotlight_config.iiif_manifest_field = :iiif_manifest_url_ssi
    spotlight_config.iiif_metadata_class = -> { Spotlight::Resources::IiifManifestMetadata }
    spotlight_config.iiif_collection_id_field = :collection_id_ssim
    spotlight_config.iiif_title_fields = nil
    spotlight_config.default_json_ld_language = 'en'

    spotlight_config.masthead_initial_crop_selection = [1200, 120]
    spotlight_config.thumbnail_initial_crop_selection = [120, 120]

    # Configure the CarrierWave file storage mechanism
    spotlight_config.uploader_storage = :file
    spotlight_config.featured_image_masthead_size = [1800, 180]
    spotlight_config.featured_image_thumb_size = [400, 300]
    spotlight_config.featured_image_square_size = [400, 400]
    spotlight_config.contact_square_size = [70, 70]

    # Additional page configurations to be made available to page editing widgets
    # See Spotlight::PageConfigurations
    spotlight_config.page_configurations = {}

    # To present curators with analytics reports on the exhibit dashboard, you need to configure
    # an Analytics provider. Google Analytics support is provided out-of-the-box.
    spotlight_config.analytics_provider = nil

    initializer 'analytics.initialize' do
      ActiveSupport::Reloader.to_prepare do
        Spotlight::Engine.config.spotlight.analytics_provider = Spotlight::Analytics::Ga
      end
    end

    initializer 'components.initialize' do
      ActiveSupport::Reloader.to_prepare do
        Spotlight::Engine.config.spotlight.header_navigation_link_component = Spotlight::HeaderNavigationLinkComponent
        Spotlight::Engine.config.spotlight.title_component = Spotlight::TitleComponent
      end
    end

    # After creating a property for your site on Google Analytics, you need to:
    # a) Enable Google Analytics API in https://console.cloud.google.com/
    # b) generate and download the JSON key and make it accessible to your application
    # (https://console.cloud.google.com/iam-admin/iam -> Service accounts -> click on service account -> keys)
    # c) set ga_property_id below to your site's property id (located in admin -> Property -> Property details upper right hand corner)
    # d) Set the ga_web_property_id. (located in admin -> Data collection and modification -> Web stream details and begins with G-)
    # ga_property_id is used for fetching analytics data from google's api, ga_web_property_id is used for sending events to GA analtyics
    # ga_web_property_id will probably change in V5 to ga_measurement_id for clarity
    spotlight_config.ga_json_key_path = nil
    spotlight_config.ga_web_property_id = nil
    spotlight_config.ga_property_id = nil
    spotlight_config.ga_analytics_options = {}
    spotlight_config.ga_page_analytics_options = spotlight_config.ga_analytics_options.merge(limit: 5)
    spotlight_config.ga_date_range = { 'start_date' => nil, 'end_date' => nil }
    spotlight_config.ga_debug_mode = false

    spotlight_config.max_pages = 1000

    Blacklight::Engine.config.inject_blacklight_helpers = false

    spotlight_config.i18n_locales = {
      ar: 'العربية',
      de: 'Deutsch',
      en: 'English',
      es: 'Español',
      fr: 'Français',
      it: 'Italiano',
      hu: 'Magyar',
      nl: 'Nederlands',
      'pt-BR': 'Português brasileiro',
      sq: 'Shqip',
      zh: '中文'
    }

    # Whitelisting the available_locales is necessary here, as any dependency we
    # add could add an available locale which could break things if unexpected.
    config.i18n.available_locales = spotlight_config.i18n_locales.keys

    # Copy of JbuilderHandler tweaked to spit out YAML for translation exports
    class TranslationYamlHandler
      cattr_accessor :default_format
      self.default_format = :yaml

      def self.call(template, source = nil)
        source ||= template.source
        # this juggling is required to keep line numbers right in the error
        %{__already_defined = defined?(json); json||=JbuilderTemplate.new(self); #{source}
          json.attributes!.to_yaml unless (__already_defined && __already_defined != "method")}
      end
    end

    initializer :yamlbuilder do
      ActiveSupport.on_load :action_view do
        ActionView::Template.register_template_handler :yamlbuilder, TranslationYamlHandler
      end
    end

    # Query parameters for autocomplete requests
    spotlight_config.autocomplete_search_field = 'autocomplete'
    spotlight_config.default_autocomplete_params = { qf: 'id^1000 full_title_tesim^100 id_ng full_title_ng',
                                                     facet: false,
                                                     'facet.field' => [] }

    spotlight_config.default_browse_index_view_type = :gallery

    # default email address to send "Report a Problem" feedback to (in addition to any exhibit-specific contacts)
    spotlight_config.default_contact_email = nil

    spotlight_config.spambot_honeypot_email_field = :email_address

    Blacklight::Configuration.default_configuration do
      # Field containing the last modified date for a Solr document
      Blacklight::Configuration.default_values[:index].timestamp_field ||= 'timestamp'

      # Default configuration for the browse view
      Blacklight::Configuration.property :browse, default: Blacklight::OpenStructWithHashAccess.new(document_actions: [])

      Blacklight::Configuration.default_values[:search_state_fields] ||= []
      Blacklight::Configuration.default_values[:search_state_fields] += %i[id exhibit_id browse_category_id]
      Blacklight::Configuration.default_values[:skip_link_component] = Spotlight::SkipLinkComponent
    end

    # make blacklight configuration play nice with bootstrap_form
    # rubocop:disable Lint/SendWithMixinArgument
    Blacklight::OpenStructWithHashAccess.send(:extend, ActiveModel::Translation)
    # rubocop:enable Lint/SendWithMixinArgument

    spotlight_config.exhibit_themes = ['default']

    spotlight_config.default_page_content_type = 'SirTrevor'

    # Added here for backwards compatability with SirTrevor 0.6
    # and apps who have customized their avaialble widgets
    spotlight_config.sir_trevor_widgets = %w[
      Heading Text List Quote Iframe Video Oembed Rule UploadedItems Browse BrowseGroupCategories LinkToSearch
      FeaturedPages SolrDocuments SolrDocumentsCarousel SolrDocumentsEmbed
      SolrDocumentsFeatures SolrDocumentsGrid SearchResults
    ]

    spotlight_config.routes = OpenStruct.new
    spotlight_config.routes.solr_documents = {}

    spotlight_config.controller_tracking_method = 'track_catalog_path'

    spotlight_config.exports = {
      attachments: true,
      blacklight_configuration: true,
      config: true,
      pages: true,
      resources: true
    }

    spotlight_config.reindexing_batch_size = nil
    spotlight_config.reindexing_batch_count = nil
    spotlight_config.hidden_job_classes = %w[Spotlight::ReindexJob]

    spotlight_config.bulk_actions_batch_size = 1000

    spotlight_config.bulk_updates = OpenStruct.new
    spotlight_config.bulk_updates.csv_id = 'Item ID'
    spotlight_config.bulk_updates.csv_title = 'Item Title'
    spotlight_config.bulk_updates.csv_visibility = 'Visibility'
    spotlight_config.bulk_updates.csv_tags_prefix = 'Tag:'
    spotlight_config.bulk_updates.csv_tags = 'Tag: %s'

    spotlight_config.assign_default_roles_to_first_user = true

    spotlight_config.exhibit_roles = %w[admin curator viewer]
    # PaperTrail serializes objects to YAML, so we need to permit these classes to be deserialized
    ActiveRecord.yaml_column_permitted_classes += [ActiveSupport::HashWithIndifferentAccess,
                                                   ActiveSupport::TimeWithZone,
                                                   ActiveSupport::TimeZone,
                                                   Time]
  end
  # rubocop:enable Metrics/ClassLength
end
