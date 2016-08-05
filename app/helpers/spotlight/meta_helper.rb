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
        card.image carrierwave_url(current_exhibit.thumbnail.image.thumb) if current_exhibit.thumbnail
      end
    end

    def exhibit_opengraph_content
      opengraph do |graph|
        graph.title current_exhibit.title
        graph.image carrierwave_url(current_exhibit.thumbnail.image.thumb) if current_exhibit.thumbnail
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
        card.image carrierwave_url(page.thumbnail.image.thumb) if page.thumbnail
      end
    end

    def page_opengraph_content(page)
      opengraph do |graph|
        graph.type 'article'
        graph.site_name application_name
        graph.title page.title
        graph.send('og:image', carrierwave_url(page.thumbnail.image.thumb)) if page.thumbnail
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
        card.image carrierwave_url(browse.thumbnail.image.thumb) if browse.thumbnail
      end
    end

    def browse_opengraph_content(browse)
      opengraph do |graph|
        graph.type 'article'
        graph.site_name application_name
        graph.title browse.title
        graph.send('og:image', carrierwave_url(browse.thumbnail.image.thumb)) if browse.thumbnail
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

    private

    def carrierwave_url(upload)
      # Carrierwave's #url returns either a full url (if asset path was configured)
      # or just the path to the image. We'll try to normalize it to a url.
      url = upload.url

      if url.nil? || url.starts_with?('http')
        url
      else
        (URI.parse(Rails.application.config.asset_host || root_url) + url).to_s
      end
    end
  end
end
