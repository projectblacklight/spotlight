# frozen_string_literal: true

module Spotlight
  ##
  # General spotlight application helpers
  module ApplicationHelper
    include CrudLinkHelpers
    include ExhibitThemeHelper
    include TitleHelper
    include MetaHelper
    include CropHelper
    include LanguagesHelper

    ##
    # Give the application name a chance to include the exhibit title
    def application_name
      name = site_title
      name ||= super

      if current_exhibit
        t :'spotlight.application_name',
          exhibit: current_exhibit.title,
          application_name: name,
          default: t('spotlight.application_name', locale: I18n.default_locale, exhibit: current_exhibit.title, application_name: name)
      else
        name
      end
    end

    def site_title
      current_site.title.presence
    end

    def content?(field)
      return content_for?(field) unless Rails.configuration.action_view.annotate_rendered_view_with_filenames && content_for(field).present?

      stripped_content = content_for(field).gsub(/<!-- BEGIN .+? -->/, '').gsub(/<!-- END .+? -->/, '').strip
      stripped_content.present?
    end

    # Returns the url for the current page in the new locale. This may be
    # overridden in downstream applications where our naive use of `url_for`
    # is insufficient to generate the expected routes
    def current_page_for_locale(locale)
      initial_exception = nil

      ([self] + additional_locale_routing_scopes).each do |scope|
        return scope.url_for(params.to_unsafe_h.merge(locale:))
      rescue ActionController::UrlGenerationError => e
        initial_exception ||= e
      end

      raise initial_exception
    end

    def additional_locale_routing_scopes
      [spotlight, main_app]
    end

    # Can search for named routes directly in the main app, omitting
    # the "main_app." prefix
    def method_missing(method, *, &)
      if main_app_url_helper?(method)
        main_app.send(method, *)
      else
        super
      end
    end

    def respond_to_missing?(method, *args)
      main_app_url_helper?(method) || super
    end

    ##
    # Override Blacklight's #document_action_path helper to add
    # the current exhibit context
    def document_action_path(action_opts, url_opts = nil)
      if current_exhibit
        model_name = current_exhibit.blacklight_config.document_model.model_name
        spotlight.send(action_opts.path || "#{action_opts.key}_exhibit_#{model_name.collection}_path", url_opts)
      else
        super
      end
    end

    ##
    # Helper to turn tag data into facets
    def url_to_tag_facet(tag)
      if current_exhibit
        search_action_url(search_state.reset.filter(:exhibit_tags).add(tag).params)
      else
        search_action_url(q: tag)
      end
    end

    ##
    # Helper to search the exhibit with a saved search's query. Falls back to the
    # default search field so that a search without a query still lands on the
    # results page instead of being redirected to the exhibit home page
    def path_to_saved_search(search)
      spotlight.search_exhibit_catalog_path(
        search.exhibit,
        search.query_params.presence || { search_field: search.blacklight_config.default_search_field.key }
      )
    end

    ##
    # Override Blacklight's #render_document_class to inject a private class
    def render_document_class(document = @document)
      [
        super,
        ("#{document_class_prefix}private" if document.private?(current_exhibit))
      ].join(' ')
    end

    # Return a copy of the blacklight configuration
    # that only includes views conifgured by our block
    def blacklight_view_config_for_search_block(block)
      return {} if block.view.blank?

      # Reject any views that aren't configured to display for this block
      blacklight_config.view.select do |view, _|
        block.view.include? view.to_s
      end
    end

    def block_document_index_view_type(block)
      views = blacklight_view_config_for_search_block(block)

      selected_view = if views.key? document_index_view_type
                        document_index_view_type
                      else
                        views.keys.first
                      end

      selected_view || default_document_index_view_type
    end

    # Return the list of views that are configured to display for a block
    def selected_search_block_views(block)
      block.as_json[:data].select do |_key, value|
        value == 'on'
      end.keys.map(&:to_s)
    end

    # Create checkbox for selecting/deselecting metadata fields for a given view in metadata configuration
    def select_deselect_action(id)
      check_box_tag(
        id,
        class: 'metadata-select',
        data: {
          behavior: 'metadata-select'
        }
      )
    end

    def uploaded_field_label(config)
      solr_field = Array(config.solr_field || config.field_name).first.to_s
      blacklight_config.index_fields[solr_field]&.label || config.label || t(".#{solr_field}")
    end

    # Render a sidecar form field for an upload field (Spotlight::UploadFieldConfig) through its configured component
    def render_upload_field_form_field(form, config, value: nil, inline: false)
      render config.component.new(
        form:,
        id: config.field_name,
        label: uploaded_field_label(config),
        value:,
        field_type: config.form_field_type,
        multiple: config.is_multiple?,
        inline:
      )
    end

    # Render a sidecar form field for an exhibit custom field through its configured component
    def render_custom_field_form_field(form, field, value: nil, inline: false)
      deprecated_partial = render_deprecated_custom_field_form_group(form, field, value:, inline:)
      return deprecated_partial if deprecated_partial

      render field.component.new(form:, id: field.slug, label: field.label, value:, field_type: field.form_field_type,
                                 multiple: field.is_multiple?, readonly: field.readonly_field?, inline:)
    end

    # Applications could previously customize custom field inputs by overriding these partials
    def render_deprecated_custom_field_form_group(form, field, value:, inline:)
      partial = "spotlight/custom_fields/form_group/#{field.field_type}"
      return unless lookup_context.exists?(partial, [], true)

      Spotlight.deprecator.warn "Rendering deprecated partial #{partial}. " \
                                'Configure a component in Spotlight::Engine.config.custom_field_types instead'
      render(partial:, locals: { inline:, f: form, field:, value: })
    end

    def available_view_fields
      current_exhibit.blacklight_configuration.default_blacklight_config.view.to_h.reject { |_k, v| v.if == false }
    end

    def render_constraints(localized_params = nil, local_search_state = nil)
      return super if defined?(super)

      local_search_state ||= convert_to_search_state(localized_params || search_state)
      constraints_component = blacklight_config&.view_config(document_index_view_type)&.constraints_component
      constraints_component ||= Blacklight::ConstraintsComponent
      render(constraints_component.new(search_state: local_search_state))
    end

    private

    def convert_to_search_state(params_or_search_state)
      if params_or_search_state.is_a? Blacklight::SearchState
        params_or_search_state
      else
        # deprecated
        controller.search_state_class.new(params_or_search_state, blacklight_config, controller)
      end
    end

    def main_app_url_helper?(method)
      method.to_s.end_with?('_path', '_url') && main_app.respond_to?(method)
    end
  end
end
