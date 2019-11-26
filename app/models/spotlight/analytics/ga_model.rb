# frozen_string_literal: true

require 'legato'

module Spotlight
  module Analytics
    ##
    # Google Analytics data model for the Exhibit dashboard
    class GaModel
      extend Legato::Model

      metrics :sessions, :users, :pageviews

      def self.context(exhibit)
        if exhibit.is_a? Spotlight::Exhibit
          for_exhibit(exhibit)
        else
          path(exhibit)
        end
      end

      def self.for_exhibit(exhibit)
        path(Spotlight::Engine.routes.url_helpers.exhibit_path(exhibit))
      end

      filter :path, &->(path) { contains(:pagePath, "^#{path}") }
    end
  end
end
