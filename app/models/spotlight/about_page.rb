module Spotlight
  class AboutPage < Spotlight::Page
    extend FriendlyId
    friendly_id :title, use: [:slugged,:scoped,:finders,:history], scope: :exhibit

    before_save do
      self.display_sidebar = true
    end

  end
end
