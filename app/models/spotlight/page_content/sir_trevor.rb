# frozen_string_literal: true

module Spotlight
  module PageContent
    # Sir-Trevor created content
    class SirTrevor
      def self.parse(page, attribute)
        content = page.read_attribute(attribute)
        content ||= [].to_json

        return [] if blocks.blank?

        if blocks.is_a?(String)
          blocks = JSON.parse(blocks, symbolize_names: true)
        end

        if blocks.is_a?(Hash)
          blocks = blocks[:data] || blocks['data'] or
            raise IndexError, "No block data found"
        end

        blocks.map do |obj|
          SirTrevorRails::Block.from_hash(obj, page)
        end
      end
    end
  end
end
