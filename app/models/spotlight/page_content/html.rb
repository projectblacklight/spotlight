# frozen_string_literal: true

module Spotlight
  module PageContent
    # HTML content created with the WYSIWYG (Tiptap) editor
    class Html
      ALLOWED_TAGS = %w[
        p br strong b em i u s del a code pre
        h2 h3 h4 ul ol li blockquote hr
        table colgroup col thead tbody tfoot tr th td
        img div
      ].freeze

      ALLOWED_ATTRIBUTES = %w[
        href rel target colspan rowspan
        src alt data-size data-align data-decorative
        data-spotlight-block data-spotlight-block-data
      ].freeze

      # SirTrevor widgets that can be embedded in HTML pages, as
      # <div data-spotlight-block="type" data-spotlight-block-data="{json}"></div>
      # (see spotlight/admin/html_editor_embed.js). They're rendered with the SirTrevor block partials.
      EMBEDDABLE_BLOCK_TYPES = %w[
        solr_documents solr_documents_grid solr_documents_carousel solr_documents_features solr_documents_embed
      ].freeze

      # Block data that HTML pages don't use (the text goes in the surrounding HTML instead)
      IGNORED_BLOCK_DATA = %w[text title format].freeze

      # Allowed values for the image attributes set by the editor (see spotlight/admin/html_editor_image.js)
      IMAGE_ATTRIBUTE_VALUES = {
        'data-size' => %w[small medium large full],
        'data-align' => %w[center left right],
        'data-decorative' => %w[true]
      }.freeze

      # Only images served over http(s) or from this site (e.g. uploaded attachments)
      IMAGE_SRC = %r{\A(https?://|/(?!/))}i

      # The embeddable block types the exhibit's widget configuration allows
      def self.embeddable_block_types
        EMBEDDABLE_BLOCK_TYPES.select { |type| Spotlight::Engine.config.sir_trevor_widgets.include?(type.camelize) }
      end

      # Split the HTML into fragments of HTML and the embedded blocks between them
      def self.parse(page, attribute)
        html = page.read_attribute(attribute)
        return [] if html.blank?

        Loofah.html5_fragment(html).children
              .slice_when { |a, b| embed?(a) || embed?(b) }
              .filter_map { |nodes| embed?(nodes.first) ? embed_block(nodes.first, page) : fragment(nodes) }
      end

      def self.fragment(nodes)
        html = nodes.map(&:to_html).join
        Fragment.new(html) if html.strip.present?
      end

      def self.embed?(node)
        node.name == 'div' && node.key?('data-spotlight-block')
      end

      def self.embed_block(node, page)
        data = embed_data(node)
        return unless data

        SirTrevorRails::Block.from_hash({ type: node['data-spotlight-block'], data: }, page)
      end

      # The embedded block's data, or nil if it's not an embeddable block
      def self.embed_data(node)
        return unless embeddable_block_types.include?(node['data-spotlight-block'])

        data = JSON.parse(node['data-spotlight-block-data'].to_s)
        data.except(*IGNORED_BLOCK_DATA) if data.is_a?(Hash)
      rescue JSON::ParserError
        nil
      end

      def self.sanitize(html)
        return html if html.blank?

        sanitized = sanitizer.sanitize(html, tags: ALLOWED_TAGS, attributes: ALLOWED_ATTRIBUTES)
        Loofah.html5_fragment(sanitized).scrub!(image_scrubber).scrub!(embed_scrubber).to_s
      end

      def self.sanitizer
        @sanitizer ||= Rails::HTML::Sanitizer.best_supported_vendor.safe_list_sanitizer.new
      end

      def self.image_scrubber
        Loofah::Scrubber.new do |node|
          next unless node.name == 'img'
          next node.remove unless IMAGE_SRC.match?(node['src'].to_s)

          IMAGE_ATTRIBUTE_VALUES.each do |name, values|
            node.remove_attribute(name) if node.key?(name) && values.exclude?(node[name])
          end
        end
      end

      # Keep only valid, top-level embedded blocks (they can't be nested in other content); other divs are unwrapped.
      # Bottom-up, so that the children of an unwrapped div have already been checked.
      def self.embed_scrubber
        Loofah::Scrubber.new(direction: :bottom_up) do |node|
          next unless node.name == 'div'

          data = embed_data(node) if embed?(node) && node.parent.fragment?
          if data
            node.children.remove
            node['data-spotlight-block-data'] = data.to_json
          else
            node.before(node.children)
            node.remove
          end
        end
      end

      # A run of HTML content, rendered as-is (after sanitizing)
      class Fragment
        attr_reader :html

        delegate :present?, to: :html

        def initialize(html)
          @html = html
        end

        def to_partial_path
          'spotlight/page_content/html_fragment'
        end

        def to_html
          Spotlight::PageContent::Html.sanitize(html).html_safe # rubocop:disable Rails/OutputSafety
        end

        def supports_alt_text?
          images.any?
        end

        # The fragment's images, in the shape of a SirTrevor block's items,
        # for the alt text report (see Spotlight::AccessibilityController)
        def item
          images.each_with_index.to_h do |image, index|
            [index.to_s, { 'alt_text' => image['alt'], 'decorative' => image['data-decorative'] }]
          end
        end

        def as_json(*)
          html
        end

        private

        def images
          @images ||= Loofah.html5_fragment(html).css('img')
        end
      end
    end
  end
end
