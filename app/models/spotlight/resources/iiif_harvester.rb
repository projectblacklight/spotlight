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

    def to_solr
      []
    end

    def harvest_resources
      parser=Spotlight::Resources::IiifParser.new(url)
      parser.items.each do |x|
        Spotlight::Resources::IiifItem.create(
          url: x[:content_metadata_iiif_manifest_ssm],
          data: x,
          exhibit: exhibit
        )
      end
    end

  end
end
