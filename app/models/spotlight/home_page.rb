module Spotlight
  class HomePage < Spotlight::Page
    extend FriendlyId
    friendly_id :title, use: [:slugged,:scoped,:finders], scope: :exhibit

    before_save :publish
    before_create :default_content

    def should_display_title?
      display_title
    end

    def display_sidebar?
      exhibit.searchable? && self.display_sidebar
    end

    private
    def self.default_content_text
      "This is placeholder content for the exhibit homepage. Curators of this exhibit can edit this page to customize it for the exhibit."
    end

    def self.default_title_text
      "Exhibit Home"
    end

    def publish
      self.published = true
    end

    def default_content
      self.title = Spotlight::HomePage.default_title_text
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
