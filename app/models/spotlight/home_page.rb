module Spotlight
  class HomePage < Spotlight::Page
    before_save do
      self.display_sidebar = true
      self.published = true
    end
    before_create do
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
    private
    def self.default_content_text
      "This is placeholder content for the exhibit homepage. Curators of this exhibit can edit this page to customize it for the exhibit."
    end
  end
end
