# frozen_string_literal: true

module Spotlight
  # Render an document suitable for embedding on a feature page.
  class SolrDocumentLegacyEmbedComponent < Blacklight::DocumentComponent
    attr_reader :block_context

    # Name `document` explicitly: ViewComponent 3 doesn't count an anonymous `**`
    # as accepting the collection parameter.
    def initialize(*, document: nil, block: nil, **)
      super(*, document:, **)

      @block_context = block
    end

    def before_render
      with_embed(block_context: block_context) unless embed

      super
    end
  end
end
