require 'nokogiri'

module Spotlight
  module Resources
    ##
    # Generic web resource harvester base module
    module Web
      extend ActiveSupport::Concern

      included do
        before_create do
          harvest!
        end
      end

      def harvest!
        response = Spotlight::Resources::Web.fetch url
        data[:headers] = response.headers
        data[:body] = response.body
      end

      def body
        harvest! if data[:body].blank?

        @body ||= Nokogiri::HTML.parse data[:body]
      end

      def self.fetch(url)
        Faraday.new(url) do |b|
          b.use FaradayMiddleware::FollowRedirects
          b.adapter :net_http
        end.get
      end
    end
  end
end
