# frozen_string_literal: true

module Spotlight
  module PageContent
    # Parser / factory for Editor.js created page content.
    # Reads the raw JSON stored in the page's content column and returns an
    # array of block objects whose #to_partial_path routes each block to its
    # own rendering partial.
    class EditorJs
      # Map Editor.js block type strings to concrete Ruby block classes.
      # Add new custom tools here as they are created.
      BLOCK_CLASSES = {
        'solr_documents' => 'Spotlight::PageContent::EditorJs::SolrDocumentsBlock'
      }.freeze

      def self.parse(page, attribute)
        raw = page.read_attribute(attribute)
        return [] if raw.blank?

        data = JSON.parse(raw, symbolize_names: true)
        (data[:blocks] || []).map { |block_hash| build_block(block_hash, page) }
      rescue JSON::ParserError
        []
      end

      def self.build_block(block_hash, page)
        type       = block_hash[:type].to_s
        klass_name = BLOCK_CLASSES[type]
        klass      = klass_name&.safe_constantize || Block
        klass.new(block_hash, page)
      end

      # ---------------------------------------------------------------------------
      # Generic block — used for any type that has no dedicated subclass
      # (e.g. the built-in EditorJS paragraph and header blocks).
      # ---------------------------------------------------------------------------
      class Block
        attr_reader :block_id, :type, :data, :page

        def initialize(hash, page = nil)
          @block_id = hash[:id].to_s
          @type     = hash[:type].to_s
          @data     = (hash[:data] || {}).with_indifferent_access
          @page     = page
        end

        # Allow hash-style access for convenience in view templates.
        def [](key)
          @data[key]
        end

        def to_partial_path
          "spotlight/editor_js/blocks/#{type}_block"
        end
      end
    end
  end
end
