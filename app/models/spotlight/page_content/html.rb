# frozen_string_literal: true

module Spotlight
  module PageContent
    # HTML content created with the WYSIWYG (Tiptap) editor
    class Html
      ALLOWED_TAGS = %w[
        p br strong b em i u s del a code pre
        h2 h3 h4 ul ol li blockquote hr
        table colgroup col thead tbody tfoot tr th td
      ].freeze

      ALLOWED_ATTRIBUTES = %w[href rel target colspan rowspan].freeze

      def self.parse(page, attribute)
        html = page.read_attribute(attribute)
        return [] if html.blank?

        [Fragment.new(html)]
      end

      def self.sanitize(html)
        return html if html.blank?

        sanitizer.sanitize(html, tags: ALLOWED_TAGS, attributes: ALLOWED_ATTRIBUTES)
      end

      def self.sanitizer
        @sanitizer ||= Rails::HTML::Sanitizer.best_supported_vendor.safe_list_sanitizer.new
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

        def supports_alt_text?
          false
        end

        def as_json(*)
          html
        end
      end
    end
  end
end
