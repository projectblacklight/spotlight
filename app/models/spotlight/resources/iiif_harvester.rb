require 'iiif/presentation'

module Spotlight::Resources
  # harvest Images from IIIF Manifest and turn them into a Spotlight::Resource
  # Note: IIIF API : http://iiif.io/api/presentation/2.0
  class IiifHarvester < Spotlight::Resource
    self.weight = -5000

    after_save :harvest_resources

    validate :is_valid_url?

    def self.can_provide? res
      is_iiif_url?(res.url)
    end

    def self.is_iiif_url? url
      valid_content_types=["application/json","application/ld+json"]
      req=Faraday.head(url)
      if req.success?
        valid_content_types.any? {|valid_type| req.headers['content-type'].include? valid_type}
      else
        false
      end
    end

    def is_valid_url?
      errors.add(:url, 'Invalid IIIF URL') unless self.class.is_iiif_url?(url)
    end

    def update_index data
      data = [data] unless data.is_a? Array
      blacklight_solr.update params: { commitWithin: 500 }, data: data.to_json, headers: { 'Content-Type' => 'application/json'} unless data.empty?
    end

    def to_solr
      []
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

    def object_manifests
      iiif_object['manifests'] || []
    end

    def object_collections
      iiif_object['collections'] || []
    end

    def object_sequences
      iiif_object['sequences'] || []
    end

    def harvest_resources
      # items.each do |x|
      #   h = convert_entry_to_solr_hash(x)
      #   puts "creating #{h.inspect}"
      #   Spotlight::Resources::Upload.create(
      #     remote_url_url: h[:url],
      #     data: h,
      #     exhibit: exhibit
      #   ) if h[:url]
      # end
    end

  end
end
