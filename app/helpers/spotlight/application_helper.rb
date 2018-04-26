module Spotlight
  ##
  # General spotlight application helpers
  module ApplicationHelper
    include CrudLinkHelpers
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
        t :'spotlight.application_name', exhibit: current_exhibit.title, application_name: name
      else
        name
      end
    end

    def site_title
      current_site.title if current_site.title.present?
    end

    # Can search for named routes directly in the main app, omitting
    # the "main_app." prefix
    def method_missing(method, *args, &block)
      if main_app_url_helper?(method)
        main_app.send(method, *args)
      else
        super
      end
    end

    def respond_to_missing?(method, *args)
      main_app_url_helper?(method) || super
    end

    ##
    # Override the Blacklight #url_for_document helper to add
    # the current exhibit context
    def url_for_document(document)
      return nil if document.nil?

      if current_exhibit
        [spotlight, current_exhibit, document]
      else
        document
      end
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
        search_action_url(search_state.reset.add_facet_params(blacklight_config.document_model.solr_field_for_tagger(current_exhibit), tag))
      else
        search_action_url(q: tag)
      end
    end

    ##
    # Override Blacklight's #render_document_class to inject a private class
    def render_document_class(document = @document)
      types = super || ''
      types << " #{document_class_prefix}private" if document.private?(current_exhibit)
      types
    end

    # Return a copy of the blacklight configuration
    # that only includes views conifgured by our block
    def blacklight_view_config_for_search_block(block)
      return {} unless block.view.present?

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

    def select_deselect_button
      button_tag(
        t(:".deselect_all"),
        class: 'btn btn-default btn-xs metadata-select',
        data: {
          behavior: 'metadata-select',
          'deselect-text' => t(:".deselect_all"),
          'select-text' => t(:".select_all")
        }
      )
    end

    def uploaded_field_label(config)
      solr_field = Array(config.solr_field || config.field_name).first.to_s
      config.label || blacklight_config.index_fields[solr_field].try(:label) || t(".#{solr_field}")
    end

    def available_view_fields
      current_exhibit.blacklight_configuration.default_blacklight_config.view.to_h.reject { |_k, v| v.if == false }
    end

    def exhibit_stylesheet_link_tag(tag)
      if current_exhibit_theme && current_exhibit.theme != 'default'
        stylesheet_link_tag "#{tag}_#{current_exhibit_theme}"
      else
        Rails.logger.warn "Exhibit theme '#{current_exhibit_theme}' not in white-list of available themes: #{Spotlight::Engine.config.exhibit_themes}"
        stylesheet_link_tag(tag)
      end
    end

    def current_exhibit_theme
      current_exhibit.theme if current_exhibit && current_exhibit.theme.present? && Spotlight::Engine.config.exhibit_themes.include?(current_exhibit.theme)
    end

    private

    def main_app_url_helper?(method)
      method.to_s.end_with?('_path', '_url') && main_app.respond_to?(method)
    end
  end
end
