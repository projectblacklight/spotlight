# WHEN 5.2 comes out this should inherit from Blaclight::DocumentPresenter
module Spotlight
  class DocumentPresenter

    # TODO remove this method when this class inherits from Blacklight::DocumentPresenter
    # @param [SolrDocument] document
    # @param [ActionController::Base] controller scope for linking and generating urls
    # @param [Blacklight::Configuration] configuration
    def initialize(document, controller, configuration = controller.blacklight_config)
      @document = document
      @configuration = configuration
      @controller = controller
    end

    def raw_document_heading
      @document[@configuration.view_config(:show).title_field].join(', ') || @document.id
    end

  end
end
