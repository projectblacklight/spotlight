# frozen_string_literal: true

module Spotlight
  module PageContent
    # HTML content created with the WYSIWYG (Tiptap) editor
    class Html
      ALLOWED_TAGS = %w[
        p br strong b em i u s del a code pre
        h2 h3 h4 ul ol li blockquote hr
        table colgroup col thead tbody tfoot tr th td
        img
      ].freeze

      ALLOWED_ATTRIBUTES = %w[
        href rel target colspan rowspan
        src alt data-size data-align data-decorative
      ].freeze

      # Allowed values for the image attributes set by the editor (see spotlight/admin/html_editor_image.js)
      IMAGE_ATTRIBUTE_VALUES = {
        'data-size' => %w[small medium large full],
        'data-align' => %w[center left right],
        'data-decorative' => %w[true]
      }.freeze

      # Only images served over http(s) or from this site (e.g. uploaded attachments)
      IMAGE_SRC = %r{\A(https?://|/(?!/))}i

      def self.parse(page, attribute)
        html = page.read_attribute(attribute)
        return [] if html.blank?

        [Fragment.new(html)]
      end

      def self.sanitize(html)
        return html if html.blank?

        sanitized = sanitizer.sanitize(html, tags: ALLOWED_TAGS, attributes: ALLOWED_ATTRIBUTES)
        Loofah.html5_fragment(sanitized).scrub!(image_scrubber).to_s
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
