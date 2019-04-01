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
# Spotlight::Engine.config.spotlight.resource_global_id_field = :"#{config.solr_fields.prefix}spotlight_resource_id#{config.solr_fields.string_suffix}"
# Spotlight::Engine.config.spotlight.full_image_field = :full_image_url_ssm
# Spotlight::Engine.config.spotlight.thumbnail_field = :thumbnail_url_ssm

# ==> Uploaded item configuration
# Spotlight::Engine.config.spotlight.upload_fields = [
#   UploadFieldConfig.new(
#     field_name: config.upload_description_field,
#     label: -> { I18n.t(:"spotlight.search.fields.#{config.upload_description_field}") },
#     form_field_type: :text_area
#   ),
#   UploadFieldConfig.new(
#     field_name: :spotlight_upload_attribution_tesim,
#     label: -> { I18n.t(:'spotlight.search.fields.spotlight_upload_attribution_tesim') }
#   ),
#   UploadFieldConfig.new(
#     field_name: :spotlight_upload_date_tesim,
#     label: -> { I18n.t(:'spotlight.search.fields.spotlight_upload_date_tesim') }
#   )
# ]
# Spotlight::Engine.config.spotlight.upload_title_field = nil # UploadFieldConfig.new(...)
# Spotlight::Engine.config.spotlight.uploader_storage = :file
# Spotlight::Engine.config.spotlight.allowed_upload_extensions = %w(jpg jpeg png)

# Spotlight::Engine.config.spotlight.featured_image_thumb_size = [400, 300]
# Spotlight::Engine.config.spotlight.featured_image_square_size = [400, 400]

# ==> Google Analytics integration
# Spotlight::Engine.config.spotlight.analytics_provider = nil
# Spotlight::Engine.config.spotlight.ga_pkcs12_key_path = nil
# Spotlight::Engine.config.spotlight.ga_web_property_id = nil
# Spotlight::Engine.config.spotlight.ga_email = nil
# Spotlight::Engine.config.spotlight.ga_analytics_options = {}
# Spotlight::Engine.config.spotlight.ga_page_analytics_options = config.ga_analytics_options.merge(limit: 5)

# ==> Sir Trevor Widget Configuration
# Spotlight::Engine.config.spotlight.sir_trevor_widgets = %w(
#   Heading Text List Quote Iframe Video Oembed Rule UploadedItems Browse
#   FeaturedPages SolrDocuments SolrDocumentsCarousel SolrDocumentsEmbed
#   SolrDocumentsFeatures SolrDocumentsGrid SearchResults
# )
#
# Page configurations made available to widgets
# Spotlight::Engine.config.spotlight.page_configurations = {
#   'my-local-config': ->(context) { context.my_custom_data_path(context.current_exhibit) }
# }
