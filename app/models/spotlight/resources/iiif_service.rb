require 'iiif/presentation'
module Spotlight
  module Resources
    ###
    # Wrapper around IIIIF-Presentation's IIIF::Service that provides the
    # ability to recursively traverse through all collections and manifests
    class IiifService
      def initialize(url)
        @url = url
      end

      def collections
        @collections ||= (object.try(:collections) || []).map do |collection|
          self.class.new(collection['@id'])
        end
      end

      def manifests
        @manifests ||= if manifest?
                         [create_iiif_manifest(object)]
                       else
                         things = []
                         things << create_iiif_manifest(object) if collection?
                         (object.try(:manifests) || []).each do |manifest|
                           things << create_iiif_manifest(
                             self.class.new(manifest['@id']).object
                           )
                         end
                         things
                       end
      end

      def self.parse(url)
        recursive_manifests(new(url))
      end

      protected

      def object
        @object ||= IIIF::Service.parse(response)
      end

      private

      attr_reader :url

      def self.recursive_manifests(thing, &block)
        return to_enum(:recursive_manifests, thing) unless block_given?

        thing.manifests.each(&block)

        thing.collections.each do |collection|
          recursive_manifests(collection, &block)
        end if thing.collections.present?
      end

      def create_iiif_manifest(manifest)
        IiifManifest.new(url: manifest['@id'], manifest: manifest)
      end

      def manifest?
        object.is_a?(IIIF::Presentation::Manifest)
      end

      def collection?
        object.is_a?(IIIF::Presentation::Collection)
      end

      def response
        @response ||= self.class.iiif_response(url)
      end

      def self.iiif_response(url)
        Faraday.get(url).body
      rescue Faraday::Error::ConnectionFailed, Faraday::TimeoutError => e
        Rails.logger.warn("HTTP GET for #{url} failed with #{e}")
        {}.to_json
      end
    end
  end
end
