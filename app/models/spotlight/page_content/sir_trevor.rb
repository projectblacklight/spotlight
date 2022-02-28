# frozen_string_literal: true

module Spotlight
  module PageContent
    # Sir-Trevor created content
    class SirTrevor
      def self.parse(page, attribute)
        blocks = page.read_attribute(attribute)
        blocks ||= [].to_json

        return [] if blocks.blank?

        blocks = JSON.parse(blocks, symbolize_names: true) if blocks.is_a?(String)

        if blocks.is_a?(Hash)
          blocks = blocks[:data] || blocks['data'] or
            raise IndexError, 'No block data found'
        end

        blocks.map do |obj|
          SirTrevorRails::Block.from_hash(obj, page)
        end
      end
    end
  end
end
