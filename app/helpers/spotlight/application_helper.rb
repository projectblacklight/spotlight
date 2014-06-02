module Spotlight
  module ApplicationHelper
    include CrudLinkHelpers
    include TitleHelper

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
        spotlight.exhibit_catalog_path(current_exhibit, document)
      else
        document
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
    # TODO remove this when we use blacklight 5.2+
    # Returns a document presenter for the given document
    def presenter(document)
      presenter_class.new(document, self)
    end

    ##
    # Override Blacklight (5.2+) so we use our own presenter
    def presenter_class
      Spotlight::DocumentPresenter
    end

    # Return a copy of the blacklight configuration
    # that only includes views conifgured by our block
    def blacklight_view_config_for_search_block sir_tervor_json
      # Reject any views that aren't configured to display for this block
      blacklight_config.view.select do |view,_|
        selected_search_block_views(sir_tervor_json).include? view.to_s
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
    def selected_search_block_views sir_tervor_json
      sir_tervor_json.select do |key, value|
        value == "on"
      end.keys
    end

    def render_save_search
      render('save_search') if render_save_this_search?
    end

    def render_save_this_search?
      (current_exhibit and can?( :curate, current_exhibit)) &&
      (params[:controller] != "spotlight_catalog_controller" && params[:action] != "admin")
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

    private

    def main_app_url_helper?(method)
        (method.to_s.end_with?('_path') or method.to_s.end_with?('_url')) and
        main_app.respond_to?(method)
    end
  end
end
