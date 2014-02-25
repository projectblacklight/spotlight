module Spotlight
  class HomePage < Spotlight::Page
    extend FriendlyId
    friendly_id :title, use: [:slugged,:scoped,:finders], scope: :exhibit

    before_save :publish
    before_create :default_content

    def title_or_default
      title.present? ? title : I18n.t('spotlight.pages.index.home_pages.title')
    end

    private
    def self.default_content_text
      "This is placeholder content for the exhibit homepage. Curators of this exhibit can edit this page to customize it for the exhibit."
    end

    def publish
      self.display_sidebar = true
      self.published = true
    end

    def default_content
      self.content = {
        "data" => [
          {"type" => "text",
           "data" => {
             "text" => Spotlight::HomePage.default_content_text
            }
          }
        ]
      }.to_json
    end
  end
end
