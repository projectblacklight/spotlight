require 'nokogiri'

class Spotlight::Resource
  module Web
    extend ActiveSupport::Concern

    included do
      before_create do
        harvest!
      end
    end

    def harvest!
      response = Spotlight::Resource::Web.fetch url
      self.data[:headers] = response.headers
      self.data[:body] = response.body
    end

    def body
      if data[:body].blank?
        harvest!
      end

      @body ||= Nokogiri::HTML.parse data[:body]
    end

    def self.fetch url
      Faraday.new(url) do |b|
        b.use FaradayMiddleware::FollowRedirects
        b.adapter :net_http
      end.get
    end

  end
end
