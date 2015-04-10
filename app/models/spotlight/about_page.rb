module Spotlight
  ##
  # About pages
  class AboutPage < Spotlight::Page
    extend FriendlyId
    friendly_id :title, use: [:slugged, :scoped, :finders, :history], scope: :exhibit
  end
end
