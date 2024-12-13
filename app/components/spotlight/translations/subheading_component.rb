# frozen_string_literal: true

module Spotlight
  module Translations
    # Draws a sub-heading for a translation.
    class SubheadingComponent < ViewComponent::Base
      def initialize(key:)
        @key = key
        super
      end

      def text
        t(@key, scope: 'spotlight.translations')
      end
    end
  end
end
