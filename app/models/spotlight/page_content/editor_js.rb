# frozen_string_literal: true

module Spotlight
  module PageContent
    # Editorjs created content
    class EditorJS
      def self.parse(page, attribute)
        Class.new do
          def initialize(page, content)
            @page = page
            @content = content
          end

          def to_partial_path
            'spotlight/editor_js/page'
          end

          def as_json
            @content.as_json
          end
        end.new(page, page.read_attribute(attribute))
      end
    end
  end
end
