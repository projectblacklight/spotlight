module Spotlight
  module PagesHelper
    def has_title? document
      document_heading(document) != document.id
    end
    def should_render_record_thumbnail_title? document, block
      has_title?(document) && block["show-title"]
    end
  end
end
