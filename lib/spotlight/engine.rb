#Load blacklight which will give spotlight views a higher preference than those in blacklight
require 'blacklight'
require 'blacklight/oembed'
require 'autoprefixer-rails'
require 'spotlight/rails/routes'
require 'spotlight/utils'
require 'friendly_id'
require 'devise'
require 'active_model_serializers'

module Spotlight
  class Engine < ::Rails::Engine
    isolate_namespace Spotlight
    # Breadcrumbs on rails must be required outside of an initializer or it doesn't get loaded.
    require 'breadcrumbs_on_rails'
    require 'carrierwave'
    require 'carrierwave/crop'
    require 'social-share-button'
    require 'lodash-rails'
    require 'github/markup'

    config.autoload_paths += %W(
      #{config.root}/app/builders
      #{config.root}/app/forms
    )

    initializer "spotlight.initialize" do
      require 'sir_trevor_rails'
      require 'cancan'
      require 'bootstrap_form'
      require 'acts-as-taggable-on'
      require 'oembed'
    end

    initializer "oembed.initialize" do
      OEmbed::Providers.register_all
    end

    Spotlight::Engine.config.resource_providers = []
    Spotlight::Engine.config.new_resource_partials = [] # e.g. "spotlight/resources/bookmarklet"
    Spotlight::Engine.config.filter_resources_by_exhibit = false
    # The allowed file extensions for uploading non-repository items.
    Spotlight::Engine.config.allowed_upload_extensions = %w(jpg jpeg png)
    
    # Suffixes for exhibit-specific solr fields
    Spotlight::Engine.config.solr_fields = OpenStruct.new
    Spotlight::Engine.config.solr_fields.prefix = "".freeze
    Spotlight::Engine.config.solr_fields.boolean_suffix = "_bsi".freeze
    Spotlight::Engine.config.solr_fields.string_suffix = "_ssim".freeze
    Spotlight::Engine.config.solr_fields.text_suffix = "_tesim".freeze

    # The solr field that original (largest) images will be stored.
    Spotlight::Engine.config.full_image_field = :full_image_url_ssm

    Spotlight::Engine.config.uploaded_description_field = :spotlight_upload_description_tesim
    Spotlight::Engine.config.uploaded_attribution_field = :spotlight_upload_attribution_tesim
    Spotlight::Engine.config.uploaded_date_field = :spotlight_upload_date_tesim

    Spotlight::Engine.config.upload_fields = [
      OpenStruct.new(solr_field: Spotlight::Engine.config.uploaded_description_field, form_field_type: :text_area),
      OpenStruct.new(solr_field: Spotlight::Engine.config.uploaded_attribution_field),
      OpenStruct.new(solr_field: Spotlight::Engine.config.uploaded_date_field)
    ]

    Blacklight::Engine.config.inject_blacklight_helpers = false
    
    # Query parameters for autocomplete requests
    Blacklight::Configuration.default_values[:default_autocomplete_solr_params] = {qf: 'id^1000 full_title_tesim^100 id_ng full_title_ng'}
    
    # Field containing the last modified date for a Solr document
    Blacklight::Configuration.default_values[:index].timestamp_field ||= 'timestamp'

    # make blacklight configuration play nice with bootstrap_form
    Blacklight::OpenStructWithHashAccess.send(:extend, ActiveModel::Translation)
  end
end
