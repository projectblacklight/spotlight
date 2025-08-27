# frozen_string_literal: true

module Spotlight
  # Render an document suitable for embedding on a feature page.
  class SolrDocumentLegacyEmbedComponent < Blacklight::DocumentComponent
    attr_reader :block_context

    def initialize(*args, block: nil, **kwargs)
      super(*args, **kwargs)

      @block_context = block
    end

    def before_render
      with_embed(block_context) unless embed

      super
    end
  end
end
