# frozen_string_literal: true

require 'iiif/presentation'
require 'iiif/v3/presentation'
require 'ssrf_filter'
module Spotlight
  module Resources
    ###
    # Wrapper around IIIF-Presentation's IIIF::Service that provides the
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
                       elsif v3_manifest?
                         [create_iiif_v3_manifest(object)]
                       else
                         build_collection_manifest.to_a
                       end
      end

      def self.parse(url)
        recursive_manifests(new(url))
      end

      protected

      def object
        # If it's a v3 manifest, the v2 library will parse it as an OrderedHash
        @object ||= parse_v2? ? manifest_v2 : manifest_v3
      end

      private

      attr_reader :url

      def parse_v2?
        manifest_v2.is_a?(IIIF::Presentation::Manifest) || manifest_v2.is_a?(IIIF::Presentation::Collection)
      end

      def manifest_v2
        @manifest_v2 ||= IIIF::Presentation::Service.parse(response)
      end

      def manifest_v3
        IIIF::V3::Presentation::Service.parse(response)
      end

      class << self
        def iiif_response(url)
          SsrfFilter.get(url, http_options: { response_body_encoding: true }).body
        rescue SsrfFilter::Error, SocketError, SystemCallError, Timeout::Error, OpenSSL::SSL::SSLError => e
          Rails.logger.warn("HTTP GET for #{url} failed with #{e}")
          {}.to_json
        end

        private

        def recursive_manifests(thing, &)
          return to_enum(:recursive_manifests, thing) unless block_given?

          thing.manifests.each(&)

          return if thing.collections.blank?

          thing.collections.each do |collection|
            recursive_manifests(collection, &)
          end
        end
      end

      def create_iiif_manifest(manifest, collection = nil)
        IiifManifest.new(url: manifest['@id'], manifest:, collection:)
      end

      def create_iiif_v3_manifest(manifest, collection = nil)
        IiifManifestV3.new(url: manifest['id'], manifest:, collection:)
      end

      def manifest?
        object.is_a?(IIIF::Presentation::Manifest)
      end

      def v3_manifest?
        object.is_a?(IIIF::V3::Presentation::Manifest)
      end

      def collection?
        object.is_a?(IIIF::Presentation::Collection)
      end

      def response
        @response ||= self.class.iiif_response(url)
      end

      def build_collection_manifest
        return to_enum(:build_collection_manifest) unless block_given?

        if collection?
          self_manifest = create_iiif_manifest(object)
          yield self_manifest
        end

        (object.try(:manifests) || []).each do |manifest|
          yield create_iiif_manifest(self.class.new(manifest['@id']).object, self_manifest)
        end
      end
    end
  end
end
