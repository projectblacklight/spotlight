# frozen_string_literal: true

# ==> User model
# Note that your chosen model must include Spotlight::User mixin
# Spotlight::Engine.config.spotlight.user_class = '::User'

# ==> Blacklight configuration
# Spotlight uses this upstream configuration to populate settings for the curator
# Spotlight::Engine.config.spotlight.catalog_controller_class = '::CatalogController'
# Spotlight::Engine.config.spotlight.default_blacklight_config = nil

# ==> Appearance configuration
# Spotlight::Engine.config.spotlight.exhibit_main_navigation = [:curated_features, :browse, :about]
# Spotlight::Engine.config.spotlight.resource_partials = [
#   'spotlight/resources/external_resources_form',
#   'spotlight/resources/upload/form',
#   'spotlight/resources/csv_upload/form',
#   'spotlight/resources/json_upload/form'
# ]
# Spotlight::Engine.config.spotlight.external_resources_partials = []
# Spotlight::Engine.config.spotlight.default_browse_index_view_type = :gallery
# Spotlight::Engine.config.spotlight.default_contact_email = nil

# ==> IIIF configuration
# Spotlight::Engine.config.spotlight.iiif_service = Spotlight::RIIIFService

# ==> Solr configuration
# Spotlight::Engine.config.spotlight.writable_index = true
# Spotlight::Engine.config.spotlight.solr_batch_size = 20
# Spotlight::Engine.config.spotlight.filter_resources_by_exhibit = true
# Spotlight::Engine.config.spotlight.autocomplete_search_field = 'autocomplete'
# Spotlight::Engine.config.spotlight.default_autocomplete_params = { qf: 'id^1000 full_title_tesim^100 id_ng full_title_ng' }

# Solr field configurations
# Spotlight::Engine.config.spotlight.solr_fields.prefix = ''.freeze
# Spotlight::Engine.config.spotlight.solr_fields.boolean_suffix = '_bsi'.freeze
# Spotlight::Engine.config.spotlight.solr_fields.string_suffix = '_ssim'.freeze
# Spotlight::Engine.config.spotlight.solr_fields.text_suffix = '_tesim'.freeze
# Spotlight::Engine.config.spotlight.resource_global_id_field = :"#{Spotlight::Engine.config.spotlight.solr_fields.prefix}spotlight_resource_id#{Spotlight::Engine.config.spotlight.solr_fields.string_suffix}"
# Exhibit custom field types; `form_field_type` and `component` control how the field renders on the upload and edit forms
# Spotlight::Engine.config.spotlight.custom_field_types = {
#   vocab: { suffix: '_ssim', facetable: true },
#   text: { suffix: '_tesim', form_field_type: :text_area, component: 'Spotlight::SidecarFormFieldComponent' }
# }
# Spotlight::Engine.config.spotlight.full_image_field = :full_image_url_ssm
# Spotlight::Engine.config.spotlight.thumbnail_field = :thumbnail_url_ssm

# ==> Uploaded item configuration
# Add `is_multiple: true` to Spotlight::UploadFieldConfig arguments to allow for multivalued field data
# Add `component: MyFieldComponent` to render the field with a custom component (default: Spotlight::SidecarFormFieldComponent)
# If is_multiple is enabled, Spotlight will send the field to Solr as an array, so ensure that your Solr configurations support this
# Spotlight::Engine.config.spotlight.upload_fields = [
#   Spotlight::UploadFieldConfig.new(
#     field_name: Spotlight::Engine.config.spotlight.upload_description_field,
#     label: -> { I18n.t(:"spotlight.search.fields.#{Spotlight::Engine.config.spotlight.upload_description_field}") },
#     form_field_type: :text_area
#   ),
#   Spotlight::UploadFieldConfig.new(
#     field_name: :spotlight_upload_attribution_tesim,
#     label: -> { I18n.t(:'spotlight.search.fields.spotlight_upload_attribution_tesim') }
#   ),
#   Spotlight::UploadFieldConfig.new(
#     field_name: :spotlight_upload_date_tesim,
#     label: -> { I18n.t(:'spotlight.search.fields.spotlight_upload_date_tesim') }
#   )
# ]
# Spotlight::Engine.config.spotlight.upload_title_field = nil # Spotlight::UploadFieldConfig.new(...)
# Spotlight::Engine.config.spotlight.uploader_storage = :file
# Spotlight::Engine.config.spotlight.allowed_upload_extensions = %w(jpg jpeg png)

# Set a delimiter character for multivalued fields in CSV uploads (ex. "|") - disabled by default
# Spotlight::Engine.config.spotlight.csv_upload_multivalued_field_delimiter = nil

# Spotlight::Engine.config.spotlight.featured_image_thumb_size = [400, 300]
# Spotlight::Engine.config.spotlight.featured_image_square_size = [400, 400]

# ==> Google Analytics integration
# After creating a property for your site on Google Analytics, you need to:
# a) Enable Google Analytics API in https://console.cloud.google.com/
# b) generate and download the JSON key and make it accessible to your application
# (https://console.cloud.google.com/iam-admin/iam -> Service accounts -> click on service account -> keys)
# c) set ga_property_id below to your site's property id (located in admin -> Property -> Property details upper right hand corner)
# d) Set the ga_measurement_id. (located in admin -> Data collection and modification -> Data Streams -> Web stream details and begins with G-)
# e) (optional) set ga_date_range. This allows you throttle the dates the user can filter by.
# ga_date_range values should use a Date object i.e. (Date.new(YYYY, MM, DD)).
# ga_measurement_id is used for sending events to GA analtyics
# ga_web_property_id is deprecated, use ga_measurement_id instead
# ga_property_id is used for fetching analytics data from google's api
# Rails.application.config.to_prepare do
#   Spotlight::Engine.config.spotlight.analytics_provider = Spotlight::Analytics::Ga
#   Spotlight::Engine.config.spotlight.ga_json_key_path = nil
#   Spotlight::Engine.config.spotlight.ga_measurement_id = 'G-XXXXXXXXXX'
#   Spotlight::Engine.config.spotlight.ga_property_id = '12345678'
#   Spotlight::Engine.config.spotlight.ga_date_range = { 'start_date' => nil, 'end_date' => nil }
#   Spotlight::Engine.config.spotlight.ga_analytics_options = {}
#   Spotlight::Engine.config.spotlight.ga_page_analytics_options = Spotlight::Engine.config.spotlight.ga_analytics_options.merge(limit: 5)
#   Spotlight::Engine.config.spotlight.ga_search_analytics_options = Spotlight::Engine.config.spotlight.ga_analytics_options.merge(limit: 11)
#   Spotlight::Engine.config.spotlight.ga_debug_mode = false
# end

# ==> Customizable settings for site tags
# When set the free text tag list field becomes multiple selection checklist
# Spotlight::Engine.config.spotlight.site_tags = []

# ==> Sir Trevor Widget Configuration
# These are set by default by Spotlight's configuration,
# but you can customize them here, or in the SirTrevorRails::Block#custom_block_types method
# Spotlight::Engine.config.spotlight.sir_trevor_widgets = %w(
#   Heading Text List Quote Iframe Video Oembed Rule UploadedItems Browse BrowseGroupCategories LinkToSearch
#   FeaturedPages SolrDocuments SolrDocumentsCarousel SolrDocumentsEmbed
#   SolrDocumentsFeatures SolrDocumentsGrid SearchResults
# )
#
# Page configurations made available to widgets
# Spotlight::Engine.config.spotlight.page_configurations = {
#   'my-local-config': ->(context) { context.my_custom_data_path(context.current_exhibit) }
# }
#
# ==> Export Configuration
# This determines what data is exported when a admin uses the exhibit export feature.
# Spotlight::Engine.config.spotlight.exports = {
#   attachments: true,
#   blacklight_configuration: true,
#   config: true,
#   pages: true,
#   resources: false
# }
