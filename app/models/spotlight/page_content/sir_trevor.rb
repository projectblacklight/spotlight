# frozen_string_literal: true

module Spotlight
  module PageContent
    # Sir-Trevor created content
    class SirTrevor
      def self.parse(page, attribute)
        content = page.read_attribute(attribute)
        content ||= [].to_json

        return SirTrevorRails::BlockArray.new if content.blank?

        SirTrevorRails::BlockArray.from_json(content, page)
      end
    end
  end
end
