module Spotlight
  class TitleComponent
    def initialize(title:, subtitle:)
      @title = title
      @subtitle = subtitle
    end

    def title
      tag.h1 @title, class: 'site-title h2'
    end

    def subtitle
      return unless @subtitle

      tag.small(@subtitle, class: 'd-none d-md-block py-2 fs-4')
    end
  end
end
