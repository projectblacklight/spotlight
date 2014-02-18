module Spotlight
  module PagesHelper
    def has_title? document
      document_heading(document) != document.id
    end
    def should_render_record_thumbnail_title? document, block
      has_title?(document) && block["show-title"]
    end
    def home_page_or_default_title(page = current_exhibit.home_page)
      if page.title.present?
        page.title
      else
        t('spotlight.pages.index.home_pages.title')
      end
    end
  end
end
