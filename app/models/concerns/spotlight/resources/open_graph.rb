module Spotlight
  module Resources
    ##
    # OpenGraph metadata harvester
    module OpenGraph
      extend ActiveSupport::Concern
      include Spotlight::Resources::Web

      def opengraph
        @opengraph ||= begin
          page = {}

          body.css('meta').select { |m| m.attribute('property') }.each do |m|
            page[m.attribute('property').to_s] = m.attribute('content').to_s
          end

          page
        end
      end

      def opengraph_properties
        Hash[opengraph.map do |k, v|
          ["#{k.parameterize('_')}_tesim", v]
        end]
      end

      def to_solr
        super.merge(opengraph_properties)
      end
    end
  end
end
