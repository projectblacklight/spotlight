require 'iiif/presentation'

# s=Spotlight::Resources::IiifHarvester.new
# s.url='http://iiif.biblissima.fr/manifests/ark:/12148/btv1b8438663z/manifest.json'
# s.exhibit=Spotlight::Exhibit.first
# s.save

module Spotlight::Resources
  class IiifParser

    attr_reader :url

    def initialize(url)
      @url=url
    end

    def items

      if is_manifest?
        [process_manifest(iiif_object)]
        # TODO create correct objects that can be iterated over in iiif_harvester
      elsif is_collection?
        []
        # TODO iterate through collections to get down to manifest level, and then do those
      end

    end

    # response body from IIIF URL
    def response_body
      @response_body ||= Faraday.get(url).body
    end

    # the parsed IIIF object
    def iiif_object
      @iiif_object ||= IIIF::Service.parse(response_body)
    end

    # is the url a IIIF manifest?
    def is_manifest?
      iiif_object.class == IIIF::Presentation::Manifest
    end

    # is the url a IIIF collection (which can include collections and manifests)?
    def is_collection?
      iiif_object.class == IIIF::Presentation::Collection
    end

    def metadata
      iiif_object['metadata'] || []
    end

    def manifests
      iiif_object['manifests'] || []
    end

    def collections
      iiif_object['collections'] || []
    end

    # turns a manifest sequence node into a single solr document (with possibly many images)
    # this will flatten all sequences and any images it contains into a single structure
    def process_manifest(iiif_object)

      solr_doc_hash={}

      image_urls=iiif_object['sequences'].flat_map(&:canvases).flat_map(&:images).flat_map(&:resource).map do |resource|
        next unless resource
        image_url=resource.service['@id']
        image_url="#{image_url}/info.json" unless image_url.downcase.ends_with?("/info.json")
      end

      solr_doc_hash[:content_metadata_image_iiif_info_ssm]=image_urls.uniq.compact
      solr_doc_hash[:content_metadata_iiif_manifest_ssm]=iiif_object['@id']
      # TODO get metadata, not just URL

      solr_doc_hash

    end


  end
end
