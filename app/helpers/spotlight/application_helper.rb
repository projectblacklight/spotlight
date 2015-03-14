module Spotlight
  module ApplicationHelper
    include CrudLinkHelpers
    include TitleHelper
    include JcropHelper

    def application_name
      name = super

      if current_exhibit
        t :'spotlight.application_name', exhibit: current_exhibit.title, application_name: name
      else
        name
      end
    end

    # Can search for named routes directly in the main app, omitting
    # the "main_app." prefix
    def method_missing method, *args, &block
      if main_app_url_helper?(method)
        main_app.send(method, *args)
      else
        super
      end
    end

    def respond_to?(method, *args)
      main_app_url_helper?(method) or super
    end

    def url_for_document document
      return nil if document.nil?

      if current_exhibit
        [spotlight, current_exhibit, document]
      else
        document
      end
    end

    def document_action_path action_opts, url_opts = nil
      if current_exhibit
        spotlight.send(action_opts.path || "exhibit_#{action_opts.key}_#{controller_name}_path", url_opts)
      else
        super
      end
    end

    def url_to_tag_facet tag
      if current_exhibit
        search_action_url(add_facet_params(Spotlight::SolrDocument.solr_field_for_tagger(current_exhibit), tag, {}))
      else
        search_action_url(q: tag)
      end
    end

    ##
    # Overridden from Blacklight to inject a private class
    def render_document_class(document = @document)
      types = super || ""
      types << " #{document_class_prefix}private" if document.private?(current_exhibit)
      types
    end

    # Return a copy of the blacklight configuration
    # that only includes views conifgured by our block
    def blacklight_view_config_for_search_block block
      # Reject any views that aren't configured to display for this block
      blacklight_config.view.select do |view,_|
        block.view.include? view.to_s
      end
    end
    
    def block_document_index_view_type block
      views = blacklight_view_config_for_search_block(block)
      
      if views.has_key? document_index_view_type
        document_index_view_type
      else
        views.keys.first
      end
    end

    # Return the list of views that are configured to display for a block
    def selected_search_block_views block
      block.as_json[:data].select do |key, value|
        value == "on"
      end.keys.map { |x| x.to_s }
    end

    def select_deselect_button
      button_tag(
        t(:".deselect_all"),
        class: "btn btn-default btn-xs metadata-select",
        data: {
          :behavior        => "metadata-select",
          :'deselect-text' => t(:".deselect_all"),
          :'select-text'   => t(:".select_all")
        }
      )
    end

    def add_exhibit_twitter_card_content
      twitter_card('summary') do |card|
        card.url exhibit_root_url(current_exhibit)
        card.title current_exhibit.title
        card.description current_exhibit.subtitle
        card.image carrierwave_url(current_exhibit.thumbnail.image.thumb) if current_exhibit.thumbnail
      end
    end

    def carrierwave_url upload
      # Carrierwave's #url returns either a full url (if asset path was configured)
      # or just the path to the image. We'll try to normalize it to a url.
      url = upload.url

      if url.nil? or url.starts_with? "http"
        url
      else
        (Rails.application.config.asset_host || root_url).sub(/\/$/, "") + url
      end
    end

    def render_save_this_search?
      (current_exhibit and can?( :curate, current_exhibit)) &&
      !(params[:controller] == "spotlight/catalog" && params[:action] == "admin")
    end

    def uploaded_field_label config
      solr_field = Array(config.solr_field || config.field_name).first.to_s
      config.label || blacklight_config.index_fields[solr_field].try(:label) || t(".#{solr_field}")
    end

    def view_label view
      t(:"blacklight.search.view.#{view}", default: blacklight_config.view[view].title || view.to_s)
    end
    
    def available_view_fields
      current_exhibit.blacklight_configuration.default_blacklight_config.view.to_h.reject { |k,v| v.if === false}
    end

    private

    def main_app_url_helper?(method)
        (method.to_s.end_with?('_path') or method.to_s.end_with?('_url')) and
        main_app.respond_to?(method)
    end
  end
end
