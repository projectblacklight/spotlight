# frozen_string_literal: true

module Spotlight
  # Factory for picking the right page content renderer
  module PageContent
    def self.for(page, attribute)
      content_type = page.content_type
      content_class = Spotlight::PageContent.const_get(content_type) if Spotlight::PageContent.const_defined?(content_type)
      content_class ||= default_page_content_class

      content_class.parse(page, attribute)
    end

    def self.default_page_content_class
      Spotlight::PageContent.const_get(Spotlight::Engine.config.default_page_content_type)
    end
  end
end
