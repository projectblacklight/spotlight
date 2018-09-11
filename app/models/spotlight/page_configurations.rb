module Spotlight
  ##
  # PageConfigurations is a simple class to gather and return all
  # configurations needed for the various SirTrevor widgets.
  # A downstream application (or gem) can inject its own data through the Spotlight's engine config like so
  # Spotlight::Engine.config.page_configurations = {
  #   'my-key': 'my_val'
  # }
  # You can also pass anything that responds to #call (eg. a lambda or custom ruby class)
  # as the value and it will be evaluted within the PageConfiguration context
  # (which has access to the view context).
  # Spotlight::Engine.config.page_configurations = {
  #   'exhibit-path': ->(context) { context.spotlight.exhibit_path(context.current_exhibit) }
  # }
  class PageConfigurations
    delegate :available_view_fields,
             :blacklight_config,
             :current_exhibit,
             :document_show_link_field,
             :index_fields,
             :index_field_label,
             :spotlight,
             :t,
             :view_label,
             to: :context

    attr_reader :context, :page
    def initialize(context:, page:)
      @context = context
      @page = page
    end

    def as_json(*)
      {
        'blacklight-configuration-index-fields': available_index_fields,
        'blacklight-configuration-search-views': available_view_configs,
        'attachment-endpoint': attachment_endpoint,
        'autocomplete-exhibit-catalog-path': exhibit_autocomplete_endpoint,
        'autocomplete-exhibit-pages-path': page_autocomplete_endpoint,
        'autocomplete-exhibit-searches-path': search_autocomplete_endpoint,
        'preview-url': page_preview_url
      }.merge(downstream_parameters)
    end

    private

    def available_index_fields
      fields = blacklight_config.index_fields.map { |k, _v| { key: k, label: index_field_label(nil, k) } }
      fields.unshift(key: document_show_link_field, label: t(:'spotlight.pages.form.title_placeholder')) unless index_fields.include? document_show_link_field

      fields
    end

    def available_view_configs
      available_view_fields.map { |k, _| { key: k, label: view_label(k) } }
    end

    def attachment_endpoint
      spotlight.exhibit_attachments_path(current_exhibit)
    end

    def exhibit_autocomplete_endpoint
      spotlight.autocomplete_exhibit_catalog_path(current_exhibit, q: '%QUERY', format: 'json')
    end

    def page_autocomplete_endpoint
      spotlight.exhibit_pages_path(current_exhibit, format: 'json')
    end

    def search_autocomplete_endpoint
      spotlight.exhibit_searches_path(current_exhibit, format: 'json')
    end

    def page_preview_url
      return unless page.persisted?

      spotlight.exhibit_preview_block_path(current_exhibit, page)
    end

    def downstream_parameters
      configured_params.each_with_object({}) do |(key, value), hsh|
        hsh[key] = if value.respond_to?(:call)
                     value.call(self)
                   else
                     value
                   end
      end
    end

    def configured_params
      Spotlight::Engine.config.page_configurations || {}
    end
  end
end
