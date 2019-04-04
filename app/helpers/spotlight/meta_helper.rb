# frozen_string_literal: true

module Spotlight
  # HTML <meta> tag helpers
  module MetaHelper
    def add_exhibit_meta_content
      exhibit_twitter_card_content
      exhibit_opengraph_content
    end

    def exhibit_twitter_card_content
      twitter_card('summary') do |card|
        card.url exhibit_root_url(current_exhibit)
        card.title current_exhibit.title
        card.description current_exhibit.subtitle
        card.image meta_image if current_exhibit.thumbnail
      end
    end

    def meta_image
      current_exhibit.thumbnail.iiif_url
    end

    def exhibit_opengraph_content
      opengraph do |graph|
        graph.title current_exhibit.title
        graph.image meta_image if current_exhibit.thumbnail
        graph.site_name site_title
      end
    end

    def add_page_meta_content(page)
      page_twitter_card_content(page)
      page_opengraph_content(page)
    end

    def page_twitter_card_content(page)
      twitter_card('summary_large_image') do |card|
        card.title page.title
        card.image page.thumbnail.iiif_url if page.thumbnail
      end
    end

    def page_opengraph_content(page)
      opengraph do |graph|
        graph.type 'article'
        graph.site_name application_name
        graph.title page.title
        graph.send('og:image', page.thumbnail.iiif_url) if page.thumbnail
        graph.send('article:published_time', page.created_at.iso8601)
        graph.send('article:modified_time', page.updated_at.iso8601)
      end
    end

    def add_browse_meta_content(browse)
      browse_twitter_card_content(browse)
      browse_opengraph_content(browse)
    end

    def browse_twitter_card_content(browse)
      twitter_card('summary_large_image') do |card|
        card.title browse.title
        card.image browse.thumbnail.iiif_url if browse.thumbnail
      end
    end

    def browse_opengraph_content(browse)
      opengraph do |graph|
        graph.type 'article'
        graph.site_name application_name
        graph.title browse.title
        graph.send('og:image', browse.thumbnail.iiif_url) if browse.thumbnail
        graph.send('article:published_time', browse.created_at.iso8601)
        graph.send('article:modified_time', browse.updated_at.iso8601)
      end
    end

    def add_document_meta_content(document)
      document_twitter_card_content(document)
      document_opengraph_content(document)
    end

    def document_twitter_card_content(document)
      presenter = show_presenter(document)

      twitter_card('summary_large_image') do |card|
        card.title presenter.heading
        card.image document.first(blacklight_config.index.thumbnail_field)
      end
    end

    def document_opengraph_content(document)
      presenter = show_presenter(document)

      opengraph do |graph|
        graph.site_name application_name
        graph.title presenter.heading
        graph.send('og:image', document.first(blacklight_config.index.thumbnail_field))
      end
    end
  end
end
